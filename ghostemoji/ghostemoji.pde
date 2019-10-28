PShape svg;

float rate = 30;
float loopTime = 1;
float t;

color bkgdColor = color(0, 0, 255);
color ghostColor = color(255, 0, 0);
color stripeColor = color(0, 255, 0);

float stripeThickness = .5;
float stripeSpacing = 100;
float thickWaveAmount = .5;

void setup() {
  size(800, 480);

  frameRate(rate);

  svg = loadShape("ghostemoji.svg");
  svg.disableStyle();
  svg.setStroke(false);
}

void draw() {
  float t = norm((frameCount / rate) % loopTime, 0, loopTime);
  float tSin = sin(t * TAU);

  background(bkgdColor);

  push();
    noStroke();
    fill(ghostColor);
    shape(svg, 0, 0);
  pop();

  push();
    blendMode(DIFFERENCE);
    fill(stripeColor);

    translate(-stripeSpacing * t, 0); // animate

    float thickMod = tSin * thickWaveAmount * (tSin > 0 ? 1 - stripeThickness : stripeThickness);
    float stripeWidth = (stripeThickness + thickMod) * stripeSpacing;
    translate(-stripeWidth / 2, 0); // center stripe

    for (float x = 0; x <= width + height + stripeSpacing; x += stripeSpacing) {
      beginShape();
        vertex(x, 0);
        vertex(x + stripeWidth, 0);
        vertex(x + stripeWidth - height, height);
        vertex(x - height, height);
      endShape(CLOSE);
    }
  pop();
}
