import pygame.midi as midi


DEVICE_ID = 0

class MidiPygame:
    events = {
        8: 'noteoff',
        9: 'noteon',
        11: 'controller',
        12: 'pgmchange',
    }

    def __init__(self):
        print('Using Pygame MIDI interface')

        midi.init()

        # for i in range(midi.get_count()):
        #     interf, name, is_input, is_output, opened = midi.get_device_info(i)
        #     print('{} {} ({}) {}'.format(interf, name,
        #             'input' if is_input else 'output' if is_output else 'none',
        #             '(open)' if opened else ''))

        self.midi_input = midi.Input(DEVICE_ID)

        self.binds = {}

    def bind(self, event, func):
        self.binds[event] = func

    def start(self):
        while True:
            if self.midi_input.poll():
                [[[status, *params], timestamp]] = self.midi_input.read(1)
                etype = status >> 4
                channel = status & 0xf
                event = self.events[etype] if etype in self.events else etype
                print('{} event, channel {}, params {}, timestamp {}'
                    .format(event, channel, params, timestamp))

                if event in self.binds:
                    self.binds[event](*params[:2])
