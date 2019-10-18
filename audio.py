# import matplotlib.pyplot as plt
import numpy as np
import pyaudio
from subprocess import Popen, PIPE
import wave

# with Popen(['glslViewer', 'circle.frag'], stdin=PIPE, stdout=PIPE) as shader:
#     print(shader.stdin)
#     print(shader.stdout)
#     shader.stdin.write()

CHUNK = 4000
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 48000
RECORD_SECONDS = 5

SINE_FREQ = 300
SINE_AMP = 16000

p = pyaudio.PyAudio()

stream = p.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)

frames = []

while True:
# for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
    data = stream.read(CHUNK)
    numpydata = np.frombuffer(data, dtype=np.int16)

    # frames.append(data)

    sine_wave = [SINE_AMP * np.cos(2 * np.pi * SINE_FREQ * x / RATE) for x in range(CHUNK)]
    sine_data = np.array(sine_wave)

    # print(numpydata)
    data_fft = np.fft.fft(numpydata)
    frequencies = np.abs(data_fft)
    print(frequencies)

    print('frequency', np.argmax(frequencies))

    # plt.plot(frequencies)
    # plt.xlim(1, 4800)

# plt.show()


stream.stop_stream()
stream.close()
p.terminate()

# wf = wave.open('output.wav', 'wb')
# wf.setnchannels(CHANNELS)
# wf.setsampwidth(p.get_sample_size(FORMAT))
# wf.setframerate(RATE)
# wf.writeframes(b''.join(frames))
# wf.close()
