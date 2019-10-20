import alsaseq


CLIENT = 24

class MidiAlsa:
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

    def __init__(self):
        print('Using ALSA MIDI interface')

        alsaseq.client('Simple', 1, 1, False) # name, ninputports, noutputports, createqueue
        alsaseq.connectfrom(0, CLIENT, 0) # inputport, src_client, src_port

        self.binds = {}

    def bind(self, event, func):
        self.binds[event] = func

    def start(self):
        while True:
            if alsaseq.inputpending():
                (etype, # enum snd_seq_event_type
                flags,
                tag,
                queue,
                timestamp,
                source,
                destination,
                data) = alsaseq.input()

                sec, msec = timestamp
                sclient, sport = source
                dclient, dport = destination

                event = self.events[etype] if etype in self.events else etype

                if event in ['controller', 'pgmchange', 'chanpress', 'pitchbend']:
                    channel, _, _, _, *params = data
                else:
                    channel, *params = data

                print('{} event, channel {}, params {}, timestamp {}'
                    .format(event, channel, params, timestamp))

                if event in self.binds:
                    self.binds[event](*params[:2])
