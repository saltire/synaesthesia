class DotMover extends Launchkey {
  // PVector[] dots = new PVector[8];
  // color[] dotColors = new color[8];

  DotMover(PApplet parent) {
    super(parent);

    // for (int i = 0; i < dots.length; i++) {
    //   dots[i] = new PVector((float(i) + 0.5) / dots.length * width, height / 2);
    //   dotColors[i] = color(255);
    //   this.padcolor(i, .75, 1);
    //   this.padcolor(i + 8, 0, 0);
    // }
  }

  // void drawDots() {
  //   for (int i = 0; i < dots.length; i++) {
  //     fill(dotColors[i]);
  //     circle(dots[i].x, dots[i].y, 10);
  //   }
  // }

  // void dial(int dial, float value) {
  //   dots[dial].y = (1 - value) * height;
  // }

  // void padon(int pad, float value) {
  //   if (pad < 8) {
  //     dotColors[pad] = color(255);
  //   this.padcolor(pad, .75, 1);
  //   this.padcolor(pad + 8, 0, 0);
  //   }
  //   else {
  //     dotColors[pad - 8] = color(255, 0, 0);
  //   this.padcolor(pad, 1, 0);
  //   this.padcolor(pad - 8, 0, 0);
  //   }
  // }
}
