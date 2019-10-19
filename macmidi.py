import colorsys
import pygame.midi as midi
import subprocess


DEVICE_ID = 0

events = {
    128: 'noteoff',
    144: 'noteon',
    176: 'control', # launchkey control
    192: 'button', # tripleplay button
}

midi.init()

# for i in range(midi.get_count()):
#     interf, name, is_input, is_output, opened = midi.get_device_info(i)
#     print('{} {} ({}) {}'.format(interf, name,
#             'input' if is_input else 'output' if is_output else 'none',
#             '(open)' if opened else ''))

midi_input = midi.Input(DEVICE_ID)

hue = 0
value = 0

with subprocess.Popen(['glslViewer', 'flat.frag'], stdin=subprocess.PIPE, encoding='utf8') as glsl:
    while True:
        if midi_input.poll():
            [[[etype, note, velocity, off_velocity], timestamp]] = midi_input.read(1)
            print('event {}, note {}, velocity {}, off_velocity {}, timestamp {}'
                .format(events[etype] if etype in events else etype,
                        note, velocity, off_velocity, timestamp))

            if etype in [128, 144, 176]:
                if etype == 144:
                    hue = (note - 40) / 50.0
                    value = velocity / 127.0 if etype == 144 else 0
                elif etype == 128:
                    value = 0
                elif etype == 176:
                    hue = (note - 21) / 8.0 # launchkey dial
                    value = velocity / 127.0

                r, g, b = colorsys.hsv_to_rgb(hue, 1.0, value)
                lines = ['u_flatcolor,{},{},{}\n'.format(r, g, b)]

                print(lines)

                try:
                    glsl.stdin.writelines(lines)
                    glsl.stdin.flush()
                except Exception as ex:
                    print('Exception:', ex)

        # elif value > 0:
        #     print('fade out')
        #     value = max(0.0, value - 0.01)

        #     r, g, b = colorsys.hsv_to_rgb(hue, 1.0, value)
        #     lines = ['u_flatcolor,{},{},{}\n'.format(r, g, b)]

        #     print(lines)

        #     try:
        #         glsl.stdin.writelines(lines)
        #         glsl.stdin.flush()
        #     except Exception as ex:
        #         print('Exception:', ex)
