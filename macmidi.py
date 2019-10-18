import pygame.midi as midi


DEVICE_ID = 24

midi.init()

midi_input = midi.Input(DEVICE_ID)

while True:
    if midi_input.poll():
        print(midi_input.read(1))
