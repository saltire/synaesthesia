PShape svg;

float rate = 30;
float loopTime = 1;

color bkgdColor = color(0, 16, 16);
color ghostColor = color(224, 224, 255);
color stripeColor = color(255);

float stripeLength;

float currentStripeAngle = TAU / 8;
float maxStripeSpinSpeed = .02 * TAU; // revolutions per frame

float currentAnimPhase = 0;
float maxStripeAnimSpeed = 20; // stripeSpacings per second

float minStripeSpacing = 10;
float maxStripeSpacing = 1000;

float maxThickWaveSpeed = 5; // undulations per second
float maxThickWaveAmount = 1;
float currentThickPhase = 0;

// float maxSineWaveHeight = 5; // relative to stripeSpacing
// float maxSineWaveLength = 5; // relative to stripeSpacing

int STRIPE_SPIN_SPEED = 21;
int STRIPE_ANIM_SPEED = 22;
int STRIPE_SPACING = 23;
int STRIPE_THICKNESS = 24;
int THICK_WAVE_AMOUNT = 25;
int THICK_WAVE_SPEED = 26;
// int SINE_WAVE_HEIGHT = 27;
// int SINE_WAVE_LENGTH = 28;

void setup() {
  size(800, 480);

  setupMidiServer();

  frameRate(rate);

  stripeLength = sqrt(width * width + height * height) * 1.25;

  svg = loadShape("ghostemoji.svg");
  svg.disableStyle();
  svg.setStroke(false);

  controls[STRIPE_SPIN_SPEED] = .5;
  controls[STRIPE_ANIM_SPEED] = .5;
  controls[STRIPE_SPACING] = .1;
  controls[STRIPE_THICKNESS] = .5;
  controls[THICK_WAVE_AMOUNT] = 0;
  controls[THICK_WAVE_SPEED] = .5;
  // controls[SINE_WAVE_HEIGHT] = 0;
  // controls[SINE_WAVE_LENGTH] = 0;
}

void draw() {
  background(bkgdColor);

  float stripeSpinSpeed = mapPosNeg(STRIPE_SPIN_SPEED, maxStripeSpinSpeed);
  float stripeAnimSpeed = mapPosNeg(STRIPE_ANIM_SPEED, maxStripeAnimSpeed);
  float stripeSpacing = mapControl(STRIPE_SPACING, minStripeSpacing, maxStripeSpacing);
  float stripeThickness = controls[STRIPE_THICKNESS];
  float thickWaveAmount = controls[THICK_WAVE_AMOUNT] * maxThickWaveAmount;
  float thickWaveSpeed = controls[THICK_WAVE_SPEED] * maxThickWaveSpeed;
  // float sineWaveHeight = controls[SINE_WAVE_HEIGHT] * maxSineWaveHeight;
  // float sineWaveLength = controls[SINE_WAVE_LENGTH] * maxSineWaveLength;

  push();
    noStroke();
    fill(ghostColor);
    shape(svg, 0, 0);
  pop();

  push();
    blendMode(DIFFERENCE);
    fill(stripeColor);

    translate(width / 2, height / 2);

    currentStripeAngle += stripeSpinSpeed * TAU;
    rotate(currentStripeAngle);

    currentAnimPhase = (currentAnimPhase + stripeAnimSpeed / rate) % 1;
    translate(currentAnimPhase * stripeSpacing, 0);

    currentThickPhase = (currentThickPhase + thickWaveSpeed / rate) % 1;
    float tSin = sin(currentThickPhase * TAU);
    float thickMod = tSin * thickWaveAmount * (tSin > 0 ? 1 - stripeThickness : stripeThickness);
    float stripeWidth = (stripeThickness + thickMod) * stripeSpacing;
    translate(-stripeWidth / 2, 0); // center stripe

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
