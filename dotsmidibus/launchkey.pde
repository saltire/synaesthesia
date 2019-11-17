import javax.sound.midi.*;
import themidibus.*;

Launchkey lk_;

class Launchkey {
  boolean debug = true;

  MidiBus midi;
  MidiBus control;

  // float[] dials = new float[8];
  // float[] keys = new float[128];
  // float[] pads = new float[16];
  // boolean[] buttons = new boolean[6];

  HashMap<Integer, String> buttonNames = new HashMap<Integer, String>() {{
    put(104, "sceneUp");
    put(105, "sceneDown");
    put(106, "trackLeft");
    put(107, "trackRight");
    put(108, "roundTop");
    put(109, "roundBottom");
  }};
  HashMap<Integer, String> noteButtonNames = new HashMap<Integer, String>() {{
    put(104, "roundTop");
    put(120, "roundBottom");
  }};

  Launchkey(PApplet parent) {
    lk_ = this;

    midi = new MidiBus(parent, "LK Mini MIDI", "LK Mini MIDI", "midi");
    control = new MidiBus(parent, "LK Mini InControl", "LK Mini InControl", "control");

    incontrol(true);
  }

  // Internal event handlers

  void controllerChange(int channel, int id, int value, long timestamp, String busName) {
    float fvalue = value / 127.0;
    controller(channel, id, fvalue);

    if (id >= 21 && id <= 28) {
      int dialId = id - 21;
      dial(dialId, fvalue);
    }
    else if (buttonNames.containsKey(id)) {
      String buttonName = buttonNames.get(id);
      if (fvalue == 1) buttonon(buttonName);
      else buttonoff(buttonName);
    }
  }

  void noteOn(int channel, int id, int velocity, long timestamp, String busName) {
    float fvelocity = velocity / 127.0;
    noteon(channel, id, fvelocity);

    if (busName == "midi") {
      if (channel == 0) {
        keyon(id, fvelocity);
      }
      else if (channel == 9 && id >= 36 && id <= 51) {
        if (id <= 39) padon(id - 28, fvelocity);
        else if (id <= 43) padon(id - 40, fvelocity);
        else if (id <= 47) padon(id - 32, fvelocity);
        else padon(id - 44, fvelocity);
      }
    }
    else if (busName == "control") {
      if (id >= 96 && id <= 103) padon(id - 96, fvelocity);
      else if (id >= 112 && id <= 119) padon(id - 104, fvelocity);
      else if (noteButtonNames.containsKey(id)) buttonon(noteButtonNames.get(id));
    }
  }

  void noteOff(int channel, int id, int velocity, long timestamp, String busName) {
    float fvelocity = velocity / 127.0;
    noteoff(channel, id, fvelocity);

    if (busName == "midi") {
      if (channel == 0) {
        keyoff(id, fvelocity);
      }
      else if (channel == 9 && id >= 36 && id <= 51) {
        if (id <= 39) padoff(id - 28, fvelocity);
        else if (id <= 43) padoff(id - 40, fvelocity);
        else if (id <= 47) padoff(id - 32, fvelocity);
        else padoff(id - 44, fvelocity);
      }
    }
    else if (busName == "control") {
      if (id >= 96 && id <= 103) padoff(id - 96, fvelocity);
      else if (id >= 112 && id <= 119) padoff(id - 104, fvelocity);
      else if (noteButtonNames.containsKey(id)) buttonoff(noteButtonNames.get(id));
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

  void incontrol(boolean enable) {
    if (debug) println(enable ? "Enabling" : "Disabling", "InControl");
    control.sendNoteOn(0, 12, enable ? 127 : 0);
  }

  void padcolor(int pad, float red, float green) {
    int note;
    if (pad <= 7) note = pad + 96;
    else if (pad <= 15) note = pad + 104;
    else return;

    if (debug) println("Setting pad", pad, "red", red, "green", green);
    int col = int(red * 7) + (int(green * 7) << 4);
    control.sendNoteOn(0, note, col);
  }
}

// Midibus event handlers

void controllerChange(int channel, int number, int value, long timestamp, String busName) {
  if (lk_ != null) {
    lk_.controllerChange(channel, number, value, timestamp, busName);
  }
}

void noteOn(int channel, int pitch, int velocity, long timestamp, String busName) {
  if (lk_ != null) {
    lk_.noteOn(channel, pitch, velocity, timestamp, busName);
  }
}

void noteOff(int channel, int pitch, int velocity, long timestamp, String busName) {
  if (lk_ != null) {
    lk_.noteOff(channel, pitch, velocity, timestamp, busName);
  }
}
