import colorsys
import os
import socket
import sys
import subprocess

# Check if we're on a linux system (i.e. the Pi).
rpi = sys.platform.startswith('linux')

if rpi:
    from midialsa import MidiAlsa as Midi
else:
    from midipygame import MidiPygame as Midi


dirname = os.path.dirname(os.path.abspath(__file__))

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 8027))
s.listen(1)

mode = '--present' if rpi else '--run'

with subprocess.Popen(['processing-java', f'--sketch={dirname}/sketch', mode],
                      stdin=subprocess.PIPE, encoding='utf8') as proc:
    conn, addr = s.accept()

    def send(string):
        conn.send(f'{string}\n'.encode('utf8'))

    def noteon(note, velocity):
        if note in range(40, 90):
            send(f'note,{note - 40},{velocity / 127.0}')

    def noteoff(note, velocity):
        if note in range(40, 90):
            send(f'note,{note - 40},0')

    def controller(control, level):
        if control in range(21, 29): # launchkey dials
            send(f'control,{control - 21},{level / 127.0}')

    midi = Midi()

    midi.bind('noteon', noteon)
    midi.bind('noteoff', noteoff)
    midi.bind('controller', controller)

    midi.start()
