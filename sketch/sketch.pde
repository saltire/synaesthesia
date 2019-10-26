void setup() {
  size(800, 480);

  setupMidiServer();
}

void draw() {
  background(0);
  fill(255);
  noStroke();

  for (int control = 0; control < controls.length; control++) {
    // println(control, controls[control]);
    if (controls[control] > 0) {
      float x = (float(control) + 0.5) / controls.length * width;
      float y = (1 - controls[control]) * height;
      circle(x, y, 10);
    }
  }
}
