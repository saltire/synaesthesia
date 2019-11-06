import pygame.midi as midi


default_device_id = 0
known_devices = [
    'Launchkey Mini MIDI 1',
    'Launchkey Mini LK Mini MIDI',
]

class MidiPygame:
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

        device_id = default_device_id
        for i in range(midi.get_count()):
            interf, name, is_input, is_output, opened = midi.get_device_info(i)
            interf = interf.decode('utf-8')
            name = name.decode('utf-8')
            imode = 'input' if is_input else 'output' if is_output else 'none'
            iopen = '(open)' if opened else ''

            if self.debug:
                print(f'{interf} / {name} ({imode}) {iopen}')

            if name in known_devices and is_input:
                device_id = i
                print(f'Using known input device {name}')
                break

        self.midi_input = midi.Input(device_id)
        self.binds = {}
        self.running = True

    def bind(self, event, func):
        self.binds[event] = func

    def start(self):
        while self.running:
            if self.midi_input.poll():
                [[[status, *params], timestamp]] = self.midi_input.read(1)
                etype = status >> 4
                channel = status & 0xf
                event = self.events[etype] if etype in self.events else etype

                if self.debug:
                    print('{} event, channel {}, params {}, timestamp {}'
                        .format(event, channel, params, timestamp))

                if 'event' in self.binds:
                    self.binds['event'](event, channel, *params[:2])
                if event in self.binds:
                    self.binds[event](channel, *params[:2])

        self.midi_input.close()

    def end(self):
        self.running = False
