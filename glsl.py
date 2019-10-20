import colorsys
import sys
import subprocess

if sys.platform.startswith('linux'):
    from midialsa import MidiAlsa as Midi
else:
    from midipygame import MidiPygame as Midi


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

    def noteon(note, velocity):
        set_color((note - 40) / 50.0, velocity / 127.0)

    def noteoff(note, velocity):
        set_color(0, 0)

    def controller(control, level):
        if control in range(21, 29): # launchkey dials
            set_color((control - 21) / 8.0, level / 127.0)

    midi = Midi()

    midi.bind('noteon', noteon)
    midi.bind('noteoff', noteoff)
    midi.bind('controller', controller)

    midi.start()
