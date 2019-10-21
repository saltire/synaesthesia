import processing.net.*;

Client netClient;


void setup() {
  size(800, 480);

  netClient = new Client(this, "127.0.0.1", 8027);
}

void draw() {
}

void clientEvent(Client client) {
  while (client.available() > 0) {
    String str = client.readStringUntil(0xa); // read until newline
    print("Got message:", str);
  }
}
