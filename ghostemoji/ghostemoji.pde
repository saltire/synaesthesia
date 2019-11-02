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
float maxGhostSize = 1.9;
float currentSizePhase = 0;

// all relative to stripeSpacing
float maxSineWaveHeight = 1;
float minSineWaveLength = .5;
float maxSineWaveLength = 20;
float sineWaveSegmentLength = .1;

int STRIPE_SPIN_SPEED = 21;
int STRIPE_ANIM_SPEED = 22;
int STRIPE_SPACING = 23;
int STRIPE_THICKNESS = 24;
int THICK_WAVE_AMOUNT = 25;
int THICK_WAVE_SPEED = 26;
int GHOST_SPIN_SPEED = 27;
int GHOST_SIZE_SPEED = 28;
// alt mode
int SINE_WAVE_HEIGHT = 27;
int SINE_WAVE_LENGTH = 28;

boolean altMode7 = false;
int ALT_MODE_7_ON = 46;
int ALT_MODE_7_OFF = 50;
boolean altMode8 = false;
int ALT_MODE_8_ON = 47;
int ALT_MODE_8_OFF = 51;

void setup() {
  // size(800, 480);
  size(1024, 768);

  setupMidiServer();

  frameRate(rate);

  canvasSize = sqrt(width * width + height * height) * 1.9;

  shapeMode(CENTER);
  strokeJoin(ROUND);
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
  // controls[SINE_WAVE_LENGTH] = .5;
}

float stripeSpinSpeed;
float stripeAnimSpeed;
float stripeSpacing;
float stripeThickness;
float minWidth;
float maxWidth;
float thickWaveSpeed;
float ghostSpinSpeed;
float ghostSizeSpeed;
float sineWaveHeight;
float sineWaveLength;

void draw() {
  if (notes[ALT_MODE_7_ON] > 0) altMode7 = true;
  if (notes[ALT_MODE_7_OFF] > 0) altMode7 = false;
  if (notes[ALT_MODE_8_ON] > 0) altMode8 = true;
  if (notes[ALT_MODE_8_OFF] > 0) altMode8 = false;

  stripeSpinSpeed = mapPosNeg(STRIPE_SPIN_SPEED, maxStripeSpinSpeed);
  stripeAnimSpeed = mapPosNeg(STRIPE_ANIM_SPEED, maxStripeAnimSpeed);
  stripeSpacing = mapControl(STRIPE_SPACING, minStripeSpacing, maxStripeSpacing);
  stripeThickness = controls[STRIPE_THICKNESS];
  minWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 0);
  maxWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 1);
  thickWaveSpeed = controls[THICK_WAVE_SPEED] * maxThickWaveSpeed;
  if (!altMode7) ghostSpinSpeed = mapPosNeg(GHOST_SPIN_SPEED, maxGhostSpinSpeed);
  if (!altMode8) ghostSizeSpeed = controls[GHOST_SIZE_SPEED] * maxGhostSizeSpeed;
  if (altMode7) sineWaveHeight = controls[SINE_WAVE_HEIGHT] * maxSineWaveHeight * stripeSpacing;
  if (altMode8) sineWaveLength = mapControl(SINE_WAVE_LENGTH, minSineWaveLength, maxSineWaveLength) * stripeSpacing;

  background(bkgdColor);
  translate(width / 2, height / 2);
  scale(height / 480.0);

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
      if (sineWaveHeight == 0) {
        line(x, 0, x, canvasSize);
      }
      else {
        beginShape();
          for (float y = 0; y <= canvasSize; y += sineWaveSegmentLength * stripeSpacing) {
            vertex(x + sin(y / sineWaveLength * TAU) * sineWaveHeight, y);
          }
        endShape();
      }
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
