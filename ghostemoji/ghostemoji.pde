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

float maxGhostHueSpeed = 5;
float currentGhostHuePhase = 0;

float maxStripeHueSpeed = 5;
float currentStripeHuePhase = 0;

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
int GHOST_HUE_SPEED = 21;
int GHOST_SAT = 22;
int STRIPE_HUE_SPEED = 23;
int STRIPE_SAT = 24;
int SINE_WAVE_HEIGHT = 27;
int SINE_WAVE_LENGTH = 28;

boolean altMode1 = false;
int ALT_MODE_1_ON = 36;
int ALT_MODE_1_OFF = 40;
boolean altMode2 = false;
int ALT_MODE_2_ON = 37;
int ALT_MODE_2_OFF = 41;
boolean altMode3 = false;
int ALT_MODE_3_ON = 38;
int ALT_MODE_3_OFF = 42;
boolean altMode4 = false;
int ALT_MODE_4_ON = 39;
int ALT_MODE_4_OFF = 43;
boolean altMode7 = false;
int ALT_MODE_7_ON = 46;
int ALT_MODE_7_OFF = 50;
boolean altMode8 = false;
int ALT_MODE_8_ON = 47;
int ALT_MODE_8_OFF = 51;

void setup() {
  // size(800, 480);
  size(1920, 1080);

  setupMidiServer();

  frameRate(rate);

  canvasSize = sqrt(width * width + height * height) * 1.9;

  colorMode(HSB, 360, 100, 100);

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
// alt mode
float ghostHueSpeed;
float ghostSat;
float stripeHueSpeed;
float stripeSat;
float sineWaveHeight;
float sineWaveLength;

void draw() {

  if (notes[ALT_MODE_1_ON] > 0) altMode1 = true;
  if (notes[ALT_MODE_1_OFF] > 0) altMode1 = false;
  if (notes[ALT_MODE_2_ON] > 0) altMode2 = true;
  if (notes[ALT_MODE_2_OFF] > 0) altMode2 = false;
  if (notes[ALT_MODE_3_ON] > 0) altMode3 = true;
  if (notes[ALT_MODE_3_OFF] > 0) altMode3 = false;
  if (notes[ALT_MODE_4_ON] > 0) altMode4 = true;
  if (notes[ALT_MODE_4_OFF] > 0) altMode4 = false;
  if (notes[ALT_MODE_7_ON] > 0) altMode7 = true;
  if (notes[ALT_MODE_7_OFF] > 0) altMode7 = false;
  if (notes[ALT_MODE_8_ON] > 0) altMode8 = true;
  if (notes[ALT_MODE_8_OFF] > 0) altMode8 = false;

  if (!altMode1) stripeSpinSpeed = mapPosNeg(STRIPE_SPIN_SPEED, maxStripeSpinSpeed);
  if (!altMode2) stripeAnimSpeed = mapPosNeg(STRIPE_ANIM_SPEED, maxStripeAnimSpeed);
  if (!altMode3) stripeSpacing = mapControl(STRIPE_SPACING, minStripeSpacing, maxStripeSpacing);
  if (!altMode4) stripeThickness = controls[STRIPE_THICKNESS];
  minWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 0);
  maxWidth = mapControl(THICK_WAVE_AMOUNT, stripeThickness, 1);
  thickWaveSpeed = controls[THICK_WAVE_SPEED] * maxThickWaveSpeed;
  if (!altMode7) ghostSpinSpeed = mapPosNeg(GHOST_SPIN_SPEED, maxGhostSpinSpeed);
  if (!altMode8) ghostSizeSpeed = controls[GHOST_SIZE_SPEED] * maxGhostSizeSpeed;
  // alt mode
  if (altMode1) ghostHueSpeed = controls[GHOST_HUE_SPEED] * maxGhostHueSpeed;
  if (altMode2) ghostSat = controls[GHOST_SAT];
  if (altMode3) stripeHueSpeed = controls[STRIPE_HUE_SPEED] * maxStripeHueSpeed;
  if (altMode4) stripeSat = controls[STRIPE_SAT];
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

    currentStripeHuePhase = (currentStripeHuePhase + stripeHueSpeed / rate) % 1;
    color stripeColor = color(currentStripeHuePhase * 360, stripeSat * 100, 100);

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

    currentGhostHuePhase = (currentGhostHuePhase + ghostHueSpeed / rate) % 1;
    color ghostColor = color(currentGhostHuePhase * 360, ghostSat * 100, 100);

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
