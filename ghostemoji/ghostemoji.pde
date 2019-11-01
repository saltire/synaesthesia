PShape svg;

float rate = 30;
float loopTime = 1;

color bkgdColor = color(0, 16, 16);
color ghostColor = color(224, 224, 255);
color stripeColor = color(255);

float canvasSize;

float currentStripeAngle = TAU / 8;
float maxStripeSpinSpeed = .01 * TAU; // revolutions per frame

float currentAnimPhase = 0;
float maxStripeAnimSpeed = 20; // stripeSpacings per second

float minStripeSpacing = 15;
float maxStripeSpacing = 1000;

float maxThickWaveSpeed = 5; // undulations per second
float maxThickWaveAmount = 1;
float currentThickPhase = 0;

float currentGhostAngle = 0;
float maxGhostSpinSpeed = .01 * TAU;

float maxGhostSizeSpeed = 5;
float minGhostSize = .1;
float maxGhostSize = 1.1;
float currentSizePhase = 0;

// float maxSineWaveHeight = 5; // relative to stripeSpacing
// float maxSineWaveLength = 5; // relative to stripeSpacing

int STRIPE_SPIN_SPEED = 21;
int STRIPE_ANIM_SPEED = 22;
int STRIPE_SPACING = 23;
int STRIPE_THICKNESS = 24;
int THICK_WAVE_AMOUNT = 25;
int THICK_WAVE_SPEED = 26;
int GHOST_SPIN_SPEED = 27;
int GHOST_SIZE_SPEED = 28;
// int SINE_WAVE_HEIGHT = 27;
// int SINE_WAVE_LENGTH = 28;

void setup() {
  size(800, 480);

  setupMidiServer();

  frameRate(rate);

  canvasSize = sqrt(width * width + height * height) * 1.9;

  shapeMode(CENTER);
  svg = loadShape("ghostemoji.svg");
  svg.disableStyle();

  controls[STRIPE_SPIN_SPEED] = .5;
  controls[STRIPE_ANIM_SPEED] = .5;
  controls[STRIPE_SPACING] = .1;
  controls[STRIPE_THICKNESS] = .5;
  controls[THICK_WAVE_AMOUNT] = 0;
  controls[THICK_WAVE_SPEED] = .5;
  controls[GHOST_SPIN_SPEED] = .5;
  controls[GHOST_SIZE_SPEED] = 0;
  // controls[SINE_WAVE_HEIGHT] = 0;
  // controls[SINE_WAVE_LENGTH] = 0;
}

void draw() {
  float stripeSpinSpeed = mapPosNeg(STRIPE_SPIN_SPEED, maxStripeSpinSpeed);
  float stripeAnimSpeed = mapPosNeg(STRIPE_ANIM_SPEED, maxStripeAnimSpeed);
  float stripeSpacing = mapControl(STRIPE_SPACING, minStripeSpacing, maxStripeSpacing);
  float stripeThickness = controls[STRIPE_THICKNESS];
  float minWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 0);
  float maxWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 1);
  float thickWaveSpeed = controls[THICK_WAVE_SPEED] * maxThickWaveSpeed;
  float ghostSpinSpeed = mapPosNeg(GHOST_SPIN_SPEED, maxGhostSpinSpeed);
  float ghostSizeSpeed = controls[GHOST_SIZE_SPEED] * maxGhostSizeSpeed;
  // float sineWaveHeight = controls[SINE_WAVE_HEIGHT] * maxSineWaveHeight;
  // float sineWaveLength = controls[SINE_WAVE_LENGTH] * maxSineWaveLength;

  background(bkgdColor);
  translate(width / 2, height / 2);

  push();
    currentStripeAngle += stripeSpinSpeed * TAU;
    rotate(currentStripeAngle);

    currentAnimPhase = (currentAnimPhase + stripeAnimSpeed / rate) % 1;
    translate(currentAnimPhase * stripeSpacing, 0);

    currentThickPhase = (currentThickPhase + thickWaveSpeed / rate) % 1;
    float tSin = sin(currentThickPhase * TAU);
    float stripeWidth = map(tSin, -1, 1, minWidth, maxWidth) * stripeSpacing;

    float startPos = ceil(canvasSize / stripeSpacing) / 2 * stripeSpacing;
    translate(-startPos, -startPos);

    noFill();
    stroke(stripeColor);
    strokeWeight(stripeWidth);
    for (float x = stripeSpacing / 2; x <= canvasSize; x += stripeSpacing) {
      line(x, 0, x, canvasSize);
    }
  pop();

  push();
    currentGhostAngle += ghostSpinSpeed * TAU;
    rotate(currentGhostAngle);

    currentSizePhase = (currentSizePhase + ghostSizeSpeed / rate) % 1;
    scale(map(sin(currentSizePhase * TAU), -1, 1, minGhostSize, maxGhostSize));

    blendMode(DIFFERENCE);
    noStroke();
    fill(ghostColor);
    shape(svg, 0, 0);
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
