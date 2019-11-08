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

  void receiveEvent(String str) {
    String[] list = str.split(",");
    String event = list[0];

    if (event.equals("controller")) {
      int channel = int(list[1]);
      int id = int(list[2]);
      float value = float(list[3]);
      controller(channel, id, value);
    }
    else if (event.equals("noteon")) {
      int channel = int(list[1]);
      int id = int(list[2]);
      float value = float(list[3]);
      noteon(channel, id, value);
    }
    else if (event.equals("noteoff")) {
      int channel = int(list[1]);
      int id = int(list[2]);
      float value = float(list[3]);
      noteoff(channel, id, value);
    }
    else if (event.equals("dial")) {
      int id = int(list[1]);
      float value = float(list[2]);
      dials[id] = value;
      dial(int(list[1]), float(list[2]));
    }
    else if (event.equals("padon")) {
      int id = int(list[1]);
      float value = float(list[2]);
      pads[id] = value;
      padon(int(list[1]), float(list[2]));
    }
    else if (event.equals("padoff")) {
      int id = int(list[1]);
      float value = float(list[2]);
      pads[id] = 0;
      padoff(int(list[1]), float(list[2]));
    }
    else if (event.equals("keyon")) {
      int id = int(list[1]);
      float value = float(list[2]);
      keys[id] = value;
      keyon(int(list[1]), float(list[2]));
    }
    else if (event.equals("keyoff")) {
      int id = int(list[1]);
      float value = float(list[2]);
      keys[id] = 0;
      keyoff(int(list[1]), float(list[2]));
    }
    else if (event.equals("buttonon")) {
      for (int i = 0; i < buttonNames.length; i++) {
        if (list[1].equals(buttonNames[i])) {
          buttons[i] = true;
          buttonon(list[1]);
        }
      }
    }
    else if (event.equals("buttonoff")) {
      for (int i = 0; i < buttonNames.length; i++) {
        if (list[1].equals(buttonNames[i])) {
          buttons[i] = false;
          buttonoff(list[1]);
        }
      }
    }
  }

  // Raw MIDI events

  void controller(int channel, int control, float value) {
    if (debug) println("controller", channel, control, ":", value);
  }

  void noteon(int channel, int note, float velocity) {
    if (debug) println("noteon", channel, note, ":", velocity);
  }

  void noteoff(int channel, int note, float velocity) {
    if (debug) println("noteoff", channel, note, ":", velocity);
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

  void buttonon(String name) {
    if (debug) println("buttonon", name);
  }

  void buttonoff(String name) {
    if (debug) println("buttonoff", name);
  }

  void keyon(int key, float velocity) {
    if (debug) println("keyon", key, ":", velocity);
  }

  void keyoff(int key, float velocity) {
    if (debug) println("keyoff", key, ":", velocity);
  }

  // Commands to send back to Launchkey

  void sendCommand(String command) {
    if (debug) println("Sending command", command);
    netClient.write(command.length());
    netClient.write(command);
  }

  void padcolor(int pad, float red, float green) {
    String[] list = { "padcolor", nf(pad), nf(int(red * 7)), nf(int(green * 7)) };
    sendCommand(join(list, ","));
  }
}

Launchkey lk_;

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline

    if (lk_ != null) {
      lk_.receiveEvent(str.trim());
    }
  }
}
