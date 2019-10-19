import pygame.midi as midi
import subprocess


DEVICE_ID = 0

events = {
    128: 'noteoff',
    144: 'noteon',
}

midi.init()

for i in range(midi.get_count()):
    interf, name, is_input, is_output, opened = midi.get_device_info(i)
    print('{} {} ({}) {}'.format(interf, name,
            'input' if is_input else 'output' if is_output else 'none',
            '(open)' if opened else ''))

midi_input = midi.Input(DEVICE_ID)

with subprocess.Popen(['glslViewer', 'flat.frag'], stdin=subprocess.PIPE, encoding='utf8') as glsl:
    while True:
        if midi_input.poll():
            [[[etype, note, velocity, off_velocity], timestamp]] = midi_input.read(1)
            print('event {}, note {}, velocity {}, off_velocity {}, timestamp {}'
                .format(events[etype] if etype in events else etype,
                        note, velocity, off_velocity, timestamp))

            if etype in [144, 128]:
                value = velocity / 127.0 if etype == 144 else 0
                lines = ['u_flatcolor,{},{},0.0\n'.format(value, value)]

                print(lines)

                try:
                    glsl.stdin.writelines(lines)
                    glsl.stdin.flush()
                except Exception as ex:
                    print('Exception:', ex)
