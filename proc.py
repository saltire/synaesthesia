import colorsys
import os
import socket
import sys
import subprocess


if sys.platform.startswith('linux'):
    from midialsa import MidiAlsa as Midi
else:
    from midipygame import MidiPygame as Midi


dirname = os.path.dirname(os.path.abspath(__file__))

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 8027))
s.listen(1)

with subprocess.Popen(['processing-java', f'--sketch={dirname}/sketch', '--present'],
                        stdin=subprocess.PIPE, encoding='utf8') as proc:
    conn, addr = s.accept()

    def set_color(hue, value):
        r, g, b = colorsys.hsv_to_rgb(hue, 1.0, value)
        line = f'u_flatcolor,{r},{g},{b}\nabcd\n'
        # print(line)
        conn.send(line.encode())

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
