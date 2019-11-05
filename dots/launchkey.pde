import processing.net.*;


class Launchkey {
  Client netClient;
  float[] controls = new float[128];
  float[] notes = new float[128];

  Launchkey(PApplet parent) {
    lk_ = this;
    netClient = new Client(parent, "127.0.0.1", 8027);
  }

  void receiveEvent(String event, int id, float value) {
    if (event.equals("controller")) {
      controls[id] = value;
      this.controller(id, value);
    }
    else if (event.equals("noteon")) {
      notes[id] = value;
      this.noteon(id, value);
    }
    else if (event.equals("noteoff")) {
      notes[id] = 0;
      this.noteoff(id, value);
    }
  }

  void controller(int control, float value) {
    println("controller", control, ":", value);
  }

  void noteon(int note, float velocity) {
    println("noteon", note, ":", velocity);
  }

  void noteoff(int note, float velocity) {
    println("noteoff", note, ":", velocity);
  }
}

Launchkey lk_;

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline
    // println("Got message:", str);

    if (lk_ != null) {
      String[] list = str.split(",");
      for (int i = 0; i < list.length; i += 3) {
        lk_.receiveEvent(list[i], int(list[i + 1]), float(list[i + 2]));
      }
    }
  }
}
