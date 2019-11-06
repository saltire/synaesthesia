class DotMover extends Launchkey {
  PVector[] dots = new PVector[8];

  DotMover(PApplet parent) {
    super(parent);

    for (int i = 0; i < dots.length; i++) {
      dots[i] = new PVector((float(i) + 0.5) / dots.length * width, height);
    }
  }

  void dial(int dial, float value) {
    dots[dial].y = (1 - value) * height;
  }
}
