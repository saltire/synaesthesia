import colorsys
import os
import socket
import sys
import subprocess

from launchkey import Launchkey


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 8027))
s.listen(1)

dirname = os.path.dirname(os.path.abspath(__file__))
sketch = sys.argv[1] if len(sys.argv) > 1 else 'sketch'
mode = '--run'
# mode = '--present'

with subprocess.Popen(['processing-java', f'--sketch={dirname}/{sketch}', mode],
                      stdin=subprocess.PIPE, encoding='utf8') as proc:
    conn, addr = s.accept()

    def send(string):
        # print('sending', string)
        conn.send(f'{string}\n'.encode('utf8'))

    def on_event(event, channel, id, value):
        # print(event, note, velocity)
        send(f'{event},{channel},{id},{value / 127.0}')

    lk = Launchkey()
    lk.bind('event', on_event)
    lk.start()

    lk.send_noteon(96, 127)
    lk.send_noteon(104, 127)

# Continue when subprocess is ended
lk.end()
