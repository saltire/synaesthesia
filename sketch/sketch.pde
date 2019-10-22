import processing.net.*;

Client netClient;

int controlCount = 8;
int noteCount = 50;

float[] controls = new float[controlCount];
float[] notes = new float[noteCount];


void setup() {
  size(800, 480);

  netClient = new Client(this, "127.0.0.1", 8027);
}

void draw() {
  background(0);
  fill(255);
  noStroke();

  for (int control = 0; control < controlCount; control++) {
    // println(control, controls[control]);
    if (controls[control] > 0) {
      float x = (float(control) + 0.5) / controlCount * width;
      float y = (1 - controls[control]) * height;
      circle(x, y, 10);
    }
  }
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
