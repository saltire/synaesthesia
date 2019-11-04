import colorsys
import os
import socket
import sys
import subprocess
import threading

# Check if we're on a linux system (i.e. the Pi). TODO: find a more specific way to identify it.
rpi = sys.platform.startswith('linux')

if rpi and False:
    from midialsa import MidiAlsa as Midi
else:
    from midipygame import MidiPygame as Midi


midi = Midi()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 8027))
s.listen(1)

dirname = os.path.dirname(os.path.abspath(__file__))
sketch = sys.argv[1] if len(sys.argv) > 1 else 'sketch'
# mode = '--present' if rpi else '--run'
mode = '--present'

with subprocess.Popen(['processing-java', f'--sketch={dirname}/{sketch}', mode],
                      stdin=subprocess.PIPE, encoding='utf8') as proc:
    conn, addr = s.accept()

    def do_midi():
        def send(string):
            # print('sending', string)
            conn.send(f'{string}\n'.encode('utf8'))

        def noteon(note, velocity):
            # print('noteon', note, velocity)
            send(f'note,{note},{velocity / 127.0}')

        def noteoff(note, velocity):
            # print('noteoff', note, velocity)
            send(f'note,{note},{velocity / 127.0}')

        def controller(control, level):
            # print('controller', control, level)
            send(f'control,{control},{level / 127.0}')

        midi.bind('noteon', noteon)
        midi.bind('noteoff', noteoff)
        midi.bind('controller', controller)

        midi.start()

    mt = threading.Thread(target=do_midi)
    mt.start()

midi.end()
