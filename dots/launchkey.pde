import processing.net.*;


class Launchkey {
  Client netClient;
  float[] controls = new float[128];
  float[] notes = new float[128];

  float[] dials = new float[8];
  float[] keys = new float[128];
  float[] pads = new float[16];
  boolean[] buttons = new boolean[6];

  int minDial = 21;
  int maxDial = 28;
  int minPad = 36;
  int maxPad = 51;
  int minButton = 104;
  int maxButton = 109;
  String[] buttonNames = {
    "sceneUp", "sceneDown", "trackLeft", "trackRight", "roundTop", "roundBottom",
  };

  boolean debug = false;

  Launchkey(PApplet parent) {
    lk_ = this;
    netClient = new Client(parent, "127.0.0.1", 8027);
  }

  int noteToPad(int note) {
    if (note <= 39) return note - 28;
    if (note <= 43) return note - 40;
    if (note <= 47) return note - 32;
    return note - 44;
  }

  void receiveEvent(String event, int channel, int id, float value) {
    if (event.equals("controller")) {
      controls[id] = value;
      controller(id, value);
      if (id >= minDial && id <= maxDial) {
        dials[id - minDial] = value;
        dial(id - minDial, value);
      }
      else if (id >= minButton && id <= maxButton) {
        int bid = id - minButton;
        if (value > 0) {
          buttons[bid] = true;
          buttonon(buttonNames[bid]);
        }
        else {
          buttons[bid] = false;
          buttonoff(buttonNames[bid]);
        }
      }
    }
    else if (event.equals("noteon")) {
      notes[id] = value;
      noteon(id, value);
      if (channel == 0) {
        keys[id] = value;
        keyon(id, value);
      }
      else if (channel == 9 && id >= minPad && id <= maxPad) {
        int pid = noteToPad(id);
        pads[pid] = value;
        padon(pid, value);
      }
    }
    else if (event.equals("noteoff")) {
      notes[id] = 0;
      noteoff(id, value);
      if (channel == 0) {
        keys[id] = 0;
        keyoff(id, value);
      }
      else if (channel == 9 && id >= minPad && id <= maxPad) {
        int pid = noteToPad(id);
        pads[pid] = 0;
        padoff(pid, value);
      }
    }
  }

  // Raw MIDI events

  void controller(int control, float value) {
    if (debug) println("controller", control, ":", value);
  }

  void noteon(int note, float velocity) {
    if (debug) println("noteon", note, ":", velocity);
  }

  void noteoff(int note, float velocity) {
    if (debug) println("noteoff", note, ":", velocity);
  }

  // Launchkey-specific events

  void dial(int dial, float value) {
    if (debug) println("dial", dial, ":", value);
  }

  void padon(int pad, float velocity) {
    if (debug) println("padon", pad, ":", velocity);
  }

  void padoff(int pad, float velocity) {
    if (debug) println("padoff", pad, ":", velocity);
  }

  void keyon(int key, float velocity) {
    if (debug) println("keyon", key, ":", velocity);
  }

  void keyoff(int key, float velocity) {
    if (debug) println("keyoff", key, ":", velocity);
  }

  void buttonon(String name) {
    if (debug) println("buttonon", name);
  }

  void buttonoff(String name) {
    if (debug) println("buttonoff", name);
  }
}

Launchkey lk_;

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline
    // println("Got message:", str);

    if (lk_ != null) {
      String[] list = str.split(",");
      for (int i = 0; i < list.length; i += 4) {
        lk_.receiveEvent(list[i], int(list[i + 1]), int(list[i + 2]), float(list[i + 3]));
      }
    }
  }
}
