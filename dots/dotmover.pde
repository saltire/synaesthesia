class DotMover extends Launchkey {
  PVector[] dots = new PVector[8];

  DotMover(PApplet parent) {
    super(parent);

    for (int i = 0; i < dots.length; i++) {
      dots[i] = new PVector((float(i) + 0.5) / dots.length * width, height);
    }
  }

  void controller(int control, float value) {
    if (control >= 21 && control <= 28) {
      dots[control - 21].y = (1 - value) * height;
    }
  }
}
