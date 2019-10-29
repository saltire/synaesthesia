int num = 1000;
float[] vx = new float[num];
float[] vy = new float[num];
float[] x = new float[num];
float[] y = new float[num];
float[] ax = new float[num];
float[] ay = new float[num];

float magnetism = 10.0;
int radius = 1 ;
float gensoku = 0.95;

void setup() {
  noStroke();
  fill(0);
  ellipseMode(RADIUS);
  background(0);
  blendMode(ADD);
  size(600, 600);

  for (int i = 0; i < num; i++) {
    x[i] = random(width);
    y[i] = random(height);
    vx[i] = 0;
    vy[i] = 0;
    ax[i] = 0;
    ay[i] = 0;
  }
}

void draw() {
  fill(0, 0, 0);
  rect(0, 0, width, height);

  for (int i = 0; i < num; i++) {
    float distance = dist(mouseX, mouseY, x[i], y[i]);
    if (distance > 3) {
      ax[i] = magnetism * (mouseX - x[i]) / (distance * distance);
      ay[i] = magnetism * (mouseY - y[i]) / (distance * distance);
    }
    vx[i] += ax[i];
    vy[i] += ay[i];

    vx[i] = vx[i] * gensoku;
    vy[i] = vy[i] * gensoku;

    x[i] += vx[i];
    y[i] += vy[i];

    float sokudo = dist(0, 0, vx[i], vy[i]);
    float r = map(sokudo, 0, 5, 0, 255);
    float g = map(sokudo, 0, 5, 64, 255);
    float b = map(sokudo, 0, 5, 128, 255);
    fill(r, g, b, 32);
    ellipse(x[i], y[i], radius, radius);
  }
}
