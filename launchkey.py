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

class Launchkey:
    events = {
        8: 'noteoff',
        9: 'noteon',
        11: 'controller',
        12: 'pgmchange',
    }

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

    def bind(self, event, func):
        self.binds[event] = func

    def start(self):
        self.set_incontrol(True)

        def do_loop():
            while self.running:
                self.get_events(self.midi_input)
                self.get_events(self.control_input)

            self.midi_input.close()
            self.control_input.close()
            self.control_output.close()

        loop = threading.Thread(target=do_loop)
        loop.start()

    def get_events(self, input_device):
        if input_device.poll():
            [[[status, *params], timestamp]] = input_device.read(1)
            etype = status >> 4
            channel = status & 0xf
            event = self.events[etype] if etype in self.events else etype

            if self.debug:
                print('{}, {} event, channel {}, params {}, timestamp {}'
                    .format(input_device.name, event, channel, params, timestamp))

            if 'event' in self.binds:
                self.binds['event'](event, channel, *params[:2])
            if event in self.binds:
                self.binds[event](channel, *params[:2])


    def set_incontrol(self, enable=True):
        # 144 = noteon, channel 0
        self.control_output.write([[[144, 12, 127 if enable else 0], 0]])

    def send_noteon(self, note, velocity):
        self.control_output.write([[[144, note, velocity], 0]])

    def end(self):
        self.set_incontrol(False)
        self.running = False
