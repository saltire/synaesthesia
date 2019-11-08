import threading

import pygame.midi as midi


known_midi_devices = [
    'Launchkey Mini MIDI 1',
    'Launchkey Mini LK Mini MIDI',
]
known_control_devices = [
    'Launchkey Mini InControl 1',
    'Launchkey Mini LK Mini InControl',
]
event_codes = {
    8: 'noteoff',
    9: 'noteon',
    11: 'controller',
    12: 'pgmchange',
}
button_names = {
    104: 'sceneUp',
    105: 'sceneDown',
    106: 'trackLeft',
    107: 'trackRight',
    108: 'roundTop',
    109: 'roundBottom',
}

class Launchkey:
    def __init__(self, debug=False):
        print('Using Pygame MIDI interface')
        self.debug = debug

        midi.init()

        self.midi_input = None
        self.control_input = None
        self.control_output = None
        for device_id in range(midi.get_count()):
            interf, name, is_input, is_output, opened = midi.get_device_info(device_id)
            interf = interf.decode('utf-8')
            name = name.decode('utf-8')
            imode = 'input' if is_input else 'output' if is_output else 'none'
            iopen = '(open)' if opened else ''

            if self.debug:
                print(f'{interf} / {name} ({imode}) {iopen}')

            if self.midi_input is None and name in known_midi_devices and is_input:
                self.midi_input = midi.Input(device_id)
                self.midi_input.name = f'{name} ({imode})'
                print(f'Using midi input device {name}')

            if self.control_input is None and name in known_control_devices and is_input:
                self.control_input = midi.Input(device_id)
                self.control_input.name = f'{name} ({imode})'
                print(f'Using control input device {name}')

            if self.control_output is None and name in known_control_devices and is_output:
                self.control_output = midi.Output(device_id)
                self.control_output.name = f'{name} ({imode})'
                self.set_incontrol(True)
                print(f'Using control output device {name}')

        self.binds = {}
        self.running = True
        self.done = False

    def bind(self, event, func):
        self.binds[event] = func

    def start(self):
        self.set_incontrol(True)

        def do_loop():
            while self.running:
                self.emit_events(self.midi_input)
                self.emit_events(self.control_input)

            self.done = True

        loop = threading.Thread(target=do_loop)
        loop.start()

    def emit_events(self, input_device):
        for event, channel, id, value in self.get_raw_events(input_device):
            self.emit_event(event, channel, id, value)

            if event in ['noteon', 'noteoff']:
                status = event[4:]

                if input_device == self.midi_input:
                    if channel == 0:
                        self.emit_event(f'key{status}', id, value / 127)
                    elif channel == 9 and id >= 36 and id <= 51:
                        if id <= 39:
                            self.emit_event(f'pad{status}', id - 28, value / 127)
                        elif id <= 43:
                            self.emit_event(f'pad{status}', id - 40, value / 127)
                        elif id <= 47:
                            self.emit_event(f'pad{status}', id - 32, value / 127)
                        else:
                            self.emit_event(f'pad{status}', id - 44, value / 127)

                elif input_device == self.control_input:
                    if id >= 96 and id <= 103:
                        self.emit_event(f'pad{status}', id - 96, value / 127)
                    elif id >= 112 and id <= 119:
                        self.emit_event(f'pad{status}', id - 104, value / 127)
                    elif id == 104:
                        self.emit_event(f'button{status}', 'roundTop')
                    elif id == 120:
                        self.emit_event(f'button{status}', 'roundBottom')

            elif event == 'controller':
                if id >= 21 and id <= 28:
                    self.emit_event('dial', id - 21, value / 127)
                elif id in button_names:
                    status = 'on' if value > 0 else 'off'
                    self.emit_event(f'button{status}', button_names[id])

    def get_raw_events(self, input_device):
        events = []

        while input_device and input_device.poll():
            [[[status, *params], timestamp]] = input_device.read(1)
            etype = status >> 4
            channel = status & 0xf
            event = event_codes[etype] if etype in event_codes else etype

            if self.debug:
                print('{}, {} event, channel {}, params {}, timestamp {}'
                    .format(input_device.name, event, channel, params, timestamp))

            events.append((event, channel, *params[:2]))

        return events

    def emit_event(self, event, *params):
        if self.debug:
            print('Emitting:', event, *params)
        if 'event' in self.binds:
            self.binds['event'](event, *params)
        if event in self.binds:
            self.binds[event](*params)

    def set_incontrol(self, enable=True):
        if self.control_output:
            # 144 = noteon, channel 0
            self.control_output.write([[[144, 12, 127 if enable else 0], 0]])

    def send_noteon(self, note, velocity):
        if self.control_output:
            self.control_output.write([[[144, note, velocity], 0]])

    def end(self):
        self.set_incontrol(False)
        self.running = False

        while not self.done:
            pass

        if self.midi_input:
            self.midi_input.close()
        if self.control_input:
            self.control_input.close()
        if self.control_output:
            self.control_output.close()
