PShape svg;

float rate = 30;
float loopTime = 1;

color bkgdColor = color(0, 16, 16);
color ghostColor = color(224, 224, 255);
color stripeColor = color(255);

float stripeAngle = TAU / 8;
float stripeAnimTime = .5;
float stripeThickness = .5;
float stripeSpacing = 75;
float stripeLength;

float thickWaveTime = .5;
float thickWaveAmount = .25;

float phase(float period) {
  return norm((frameCount / rate) % period, 0, period);
}

float sinePhase(float period) {
  return sin(phase(period) * TAU);
}

void setup() {
  size(800, 480);

  frameRate(rate);

  stripeLength = sqrt(width * width + height * height) * 1.25;

  svg = loadShape("ghostemoji.svg");
  svg.disableStyle();
  svg.setStroke(false);
}

void draw() {
  background(bkgdColor);

  push();
    noStroke();
    fill(ghostColor);
    shape(svg, 0, 0);
  pop();

  push();
    blendMode(DIFFERENCE);
    fill(stripeColor);

    translate(width / 2, height / 2);
    rotate(stripeAngle);

    float tSin = sinePhase(thickWaveTime);
    float thickMod = tSin * thickWaveAmount * (tSin > 0 ? 1 - stripeThickness : stripeThickness);
    float stripeWidth = (stripeThickness + thickMod) * stripeSpacing;
    translate(-stripeWidth / 2, 0); // center stripe

    translate(-stripeSpacing * phase(stripeAnimTime), 0); // animate

    translate(-stripeLength / 2, -stripeLength / 2);
    for (float x = 0; x <= stripeLength; x += stripeSpacing) {
      beginShape();
        vertex(x, 0);
        vertex(x + stripeWidth, 0);
        vertex(x + stripeWidth, stripeLength);
        vertex(x, stripeLength);
      endShape(CLOSE);
    }
  pop();
}
