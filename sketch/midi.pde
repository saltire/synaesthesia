import processing.net.*;

Client netClient;

float[] controls = new float[8];
float[] notes = new float[50];


void setupMidiServer() {
  netClient = new Client(this, "127.0.0.1", 8027);
}

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline
    // print("Got message:", str);

    String[] list = str.split(",");
    for (int i = 0; i < list.length; i += 3) {
      if (list[i].equals("control")) {
        int control = int(list[i + 1]);
        float value = float(list[i + 2]);
        controls[control] = value;
      }
      else if (list[i].equals("note")) {
        int note = int(list[i + 1]);
        float value = float(list[i + 2]);
        notes[note] = value;
      }
    }
  }
}
