import processing.net.*;

Client netClient;

float[] controls = new float[128];
float[] notes = new float[128];


void setupMidiServer() {
  netClient = new Client(this, "127.0.0.1", 8027);
}

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline
    // println("Got message:", str);

    String[] list = str.split(",");
    for (int i = 0; i < list.length; i += 3) {
      if (list[i].equals("controller")) {
        int control = int(list[i + 1]);
        float value = float(list[i + 2]);
        controls[control] = value;
        println("controller", control, ":", value);
      }
      else if (list[i].equals("noteon") || list[i].equals("noteoff")) {
        int note = int(list[i + 1]);
        float value = float(list[i + 2]);
        notes[note] = value;
        println(list[i], note, ":", value);
      }
    }
  }
}
