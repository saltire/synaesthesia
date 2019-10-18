"""
this is a stripped down version of the SWHear class.
It's designed to hold only a single audio sample in memory.
check my githib for a more complete version:
    http://github.com/swharden
"""

# originally from https://github.com/swharden/Python-GUI-examples

import pyaudio
import time
import numpy as np
import threading
# import matplotlib.pyplot as plt
import sys


def getFFT(data, rate):
    """Given some data and rate, returns FFTfreq and FFT (half)."""
    data = data * np.hamming(len(data)) # use a Hamming window to smooth out the data
    fft = np.abs(np.fft.fft(data)) # get the fourier transform
    # fft = 10 * np.log10(fft)
    freq = np.fft.fftfreq(len(fft), 1.0 / rate) # get the frequencies for the x-axis

    # return the bottom half of each array
    return freq[:int(len(freq) / 2)], fft[:int(len(fft) / 2)]

class SWHear():
    """
    The SWHear class is provides access to continuously recorded
    (and mathematically processed) microphone data.

    Arguments:

        device - the number of the sound card input to use. Leave blank
        to automatically detect one.

        rate - sample rate to use. Defaults to something supported.

        updatesPerSecond - how fast to record new data. Note that smaller
        numbers allow more data to be accessed and therefore high
        frequencies to be analyzed if using a FFT later
    """

    def __init__(self, device=None, rate=None, updatesPerSecond=10):
        self.p = pyaudio.PyAudio()
        self.chunk = 4096 # gets replaced automatically
        self.updatesPerSecond = updatesPerSecond
        self.chunksRead = 0
        self.device = device
        self.rate = rate

    ### SYSTEM TESTS

    def valid_low_rate(self, device):
        """set the rate to the lowest supported audio rate."""
        for testrate in [48000, 44100]:
            if self.valid_test(device, testrate):
                return testrate
        print("SOMETHING'S WRONG! I can't figure out how to use DEV", device)
        return None

    def valid_test(self, device, rate=44100):
        """given a device ID and a rate, return TRUE/False if it's valid."""
        try:
            self.info = self.p.get_device_info_by_index(device)
            if not self.info['maxInputChannels'] > 0:
                return False

            stream = self.p.open(format=pyaudio.paInt16, channels=1,
                                 input_device_index=device, frames_per_buffer=self.chunk,
                                 rate=rate, input=True)
            stream.close()
            return True
        except:
            return False

    def valid_input_devices(self):
        """
        See which devices can be opened for microphone input.
        call this when no PyAudio object is loaded.
        """
        mics = [device for device in range(self.p.get_device_count()) if self.valid_test(device)]
        if len(mics) == 0:
            print('no microphone devices found!')
        else:
            print('found {} microphone device(s): {}'.format(len(mics), mics))
        return mics

    ### SETUP AND SHUTDOWN

    def initiate(self):
        """run this after changing settings (like rate) before recording"""
        if self.device is None:
            self.device = self.valid_input_devices()[0] #pick the first one
        if self.rate is None:
            self.rate = self.valid_low_rate(self.device)

        if not self.valid_test(self.device, self.rate):
            print('guessing a valid microphone device/rate...')
            self.device = self.valid_input_devices()[0] #pick the first one
            self.rate = self.valid_low_rate(self.device)

        # Number of samples per update (e.g. at 10 updates/sec, hold 1/10 of a second in memory)
        self.chunk = int(self.rate / self.updatesPerSecond)
        # Time values for each sample in the chunk (not used).
        self.datax = np.arange(self.chunk) / float(self.rate)

        print('recording from "{}" (device {}) at {} Hz'
            .format(self.info['name'], self.device, self.rate))

    def close(self):
        """gently detach from things."""
        print(" -- sending stream termination command...")
        self.keepRecording = False #the threads should self-close
        while self.t.isAlive(): #wait for all threads to close
            time.sleep(.1)
        self.stream.stop_stream()
        self.p.terminate()

    ### STREAM HANDLING

    def stream_readchunk(self):
        """reads some audio and re-launches itself"""
        try:
            self.data = np.frombuffer(self.stream.read(self.chunk), dtype=np.int16)
            self.fftx, self.fft = getFFT(self.data, self.rate)

        except Exception as E:
            print(" -- exception! terminating...")
            print(E, "\n" * 5)
            self.keepRecording = False

        if self.keepRecording:
            self.stream_thread_new()
        else:
            self.stream.close()
            self.p.terminate()
            print(" -- stream STOPPED")

        self.chunksRead += 1

    def stream_thread_new(self):
        self.t = threading.Thread(target=self.stream_readchunk)
        self.t.start()

    def stream_start(self):
        """adds data to self.data until termination signal"""
        self.initiate()
        print(" -- starting stream")
        self.keepRecording = True # set this to False later to terminate stream
        self.data = None # will fill up with threaded recording data
        self.fft = None
        self.dataFiltered = None #same
        self.stream = self.p.open(format=pyaudio.paInt16, channels=1,
                                  rate=self.rate, input=True, frames_per_buffer=self.chunk)
        self.stream_thread_new()

if __name__=="__main__":
    ear = SWHear(updatesPerSecond=10) # optionally set sample rate here
    ear.stream_start() # goes forever
    lastRead = ear.chunksRead
    while True:
        # wait for new data
        while lastRead == ear.chunksRead:
            # time.sleep(.01)
            continue

        if ear.data is not None and ear.fft is not None:
            pcmMax = np.max(np.abs(ear.data))

            freq = ear.fftx
            fft = np.abs(ear.fft)
            print('Volume: {}, Frequency: {} Hz'.format(pcmMax, freq[np.argmax(fft)]))

            # plt.plot(freq, fft)
            # plt.xlim(1, 800)

        lastRead = ear.chunksRead

    # plt.show()
    print("DONE")

    ear.close()
