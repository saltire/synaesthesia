PShape svg;

float rate = 30;
float loopTime = 1;

color bkgdColor = color(0, 16, 16);
color ghostColor = color(224, 224, 255);
color stripeColor = color(255);

float maxStripeAnimSpeed = 20; // stripeWidths per second
float currentAnimOffset = 0;
float stripeThickness = .5;
float minStripeSpacing = 10;
float maxStripeSpacing = 1000;
float stripeLength;
float stripeAngle = TAU / 8;
float maxSpinSpeed = .02 * TAU; // revolutions per frame

float maxThickWaveTime = .5;
float maxThickWaveAmount = .25;

int SPIN_SPEED = 21;
int STRIPE_SPACING = 22;
int STRIPE_SPEED = 23;
int THICK_WAVE_TIME = 24;
int THICK_WAVE_AMOUNT = 25;

void setup() {
  size(800, 480);

  setupMidiServer();

  frameRate(rate);

  stripeLength = sqrt(width * width + height * height) * 1.25;

  svg = loadShape("ghostemoji.svg");
  svg.disableStyle();
  svg.setStroke(false);

  controls[SPIN_SPEED] = .5;
  controls[STRIPE_SPACING] = .1;
  controls[STRIPE_SPEED] = .5;
  controls[THICK_WAVE_TIME] = 0;
  controls[THICK_WAVE_AMOUNT] = .5;
}

void draw() {
  background(bkgdColor);

  stripeAngle += mapPosNeg(SPIN_SPEED, maxSpinSpeed);
  float stripeAnimSpeed = mapPosNeg(STRIPE_SPEED, maxStripeAnimSpeed);
  float stripeSpacing = mapControl(STRIPE_SPACING, minStripeSpacing, maxStripeSpacing);
  float thickWaveTime = controls[THICK_WAVE_TIME] * maxThickWaveTime;
  float thickWaveAmount = controls[THICK_WAVE_AMOUNT] * maxThickWaveAmount;

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

    float animPerFrame = stripeAnimSpeed * stripeWidth / rate;
    currentAnimOffset = (currentAnimOffset + animPerFrame) % stripeSpacing;
    translate(currentAnimOffset, 0);

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

float deadZone(int control, float deadZoneAmount) {
  if (controls[control] < .5 - deadZoneAmount) {
    return map(controls[control], 0, .5 - deadZoneAmount, 0, .5);
  }
  if (controls[control] > .5 + deadZoneAmount) {
    return map(controls[control], .5 + deadZoneAmount, 1, .5, 1);
  }
  return .5;
}

float mapPosNeg(int control, float absMaxValue) {
  return lerp(-absMaxValue, absMaxValue, deadZone(control, .1));
}

float mapControl(int control, float minValue, float maxValue) {
  return lerp(minValue, maxValue, controls[control]);
}

float phase(float seconds) {
  return norm((frameCount / rate) % seconds, 0, seconds);
}

float sinePhase(float seconds) {
  return sin(phase(seconds) * TAU);
}
