import alsaseq
import subprocess


CLIENT = 24

events = {
    5: 'note',
    6: 'noteon',
    7: 'noteoff',
    8: 'keypress',
    10: 'controller',
    11: 'pgmchange',
    12: 'chanpress',
    13: 'pitchbend',
}

alsaseq.client('Simple', 1, 1, False) # name, ninputports, noutputports, createqueue
alsaseq.connectfrom(0, CLIENT, 0) # inputport, src_client, src_port

with subprocess.Popen(['glslViewer', 'flat.frag'], stdin=subprocess.PIPE, encoding='utf8') as glsl:
    while True:
        if alsaseq.inputpending():
            event = alsaseq.input()

            (etype, # enum snd_seq_event_type
            flags,
            tag,
            queue,
            timestamp,
            source,
            destination,
            data) = event

            sec, msec = timestamp
            sclient, sport = source
            dclient, dport = destination

            # print(event)

            if etype in [10, 11, 12, 13]:
                channel, _, _, _, param, value = data
                print('{} event: channel {}, param {}, value {}'
                    .format(events[etype], channel, param, value))

            else:
                channel, note, velocity, off_velocity, duration = data
                print('{} event: channel {}, note {}, velocity {}, off velocity {}, duration {}'
                    .format(events[etype] if etype in events else etype, *data))

            if etype in [6, 7]:
                value = velocity / 127.0 if etype == 6 else 0
                lines = ['u_flatcolor,{},{},0.0\n'.format(value, value)]

                print(lines)

                try:
                    glsl.stdin.writelines(lines)
                    glsl.stdin.flush()
                except Exception as ex:
                    print('Exception:', ex)
