import colorsys
import os
import socket
import sys
import subprocess
import threading

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

    def on_event(event, *params):
        # print(event, note, velocity)
        send(','.join(str(arg) for arg in [event, *params]))

    lk = Launchkey(debug=True)
    lk.bind('event', on_event)
    lk.start()

    def recv_loop():
        while True:
            msglen_byte = conn.recv(1)
            if len(msglen_byte) == 0:
                break

            msglen = ord(msglen_byte)
            msg = ''
            while len(msg) < msglen:
                getlen = min(msglen, 16)
                msg += conn.recv(getlen).decode('utf-8')
                msglen -= getlen

            command, *params = msg.split(',')
            lk.receive(command, *params)

    rloop = threading.Thread(target=recv_loop)
    rloop.start()

# Continue when subprocess is ended
lk.end()

s.close()
