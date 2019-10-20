import colorsys
import pygame.midi as midi
import subprocess


DEVICE_ID = 0

events = {
    8: 'noteoff',
    9: 'noteon',
    11: 'controller',
    12: 'pgmchange',
}

midi.init()

# for i in range(midi.get_count()):
#     interf, name, is_input, is_output, opened = midi.get_device_info(i)
#     print('{} {} ({}) {}'.format(interf, name,
#             'input' if is_input else 'output' if is_output else 'none',
#             '(open)' if opened else ''))

midi_input = midi.Input(DEVICE_ID)

with subprocess.Popen(['glslViewer', 'flat.frag'], stdin=subprocess.PIPE, encoding='utf8') as glsl:
    def set_color(hue, value):
        r, g, b = colorsys.hsv_to_rgb(hue, 1.0, value)
        lines = ['u_flatcolor,{},{},{}\n'.format(r, g, b)]
        print(lines)

        try:
            glsl.stdin.writelines(lines)
            glsl.stdin.flush()
        except Exception as ex:
            print('Exception:', ex)

    while True:
        if midi_input.poll():
            [[[status, *params], timestamp]] = midi_input.read(1)
            etype = status >> 4
            channel = status & 0xf
            event = events[etype] if etype in events else etype
            print('{} event, params {}, timestamp {}'.format(event, params, timestamp))

            if event == 'noteon':
                note, velocity, _ = params
                set_color((note - 40) / 50.0, velocity / 127.0)

            elif event == 'noteoff':
                set_color(0, 0)

            elif event == 'controller':
                control, level, _ = params
                if control in range(21, 29): # launchkey dials
                    set_color((control - 21) / 8.0, level / 127.0)
