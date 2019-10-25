// adapted from http://rectangleworld.com/blog/archives/587

float cellSize = 10;
int w;
int h;

float ease = 0.67;
float velMax = 255;
float minDist = 8;
float minDistSquare = minDist * minDist;
float sepNormMag = 4;

class Cell {
  int x;
  int y;
  float r;
  float g;
  float b;
  float rNext;
  float gNext;
  float bNext;
  float rVel;
  float gVel;
  float bVel;
  float rVelNext;
  float gVelNext;
  float bVelNext;
  Cell[] neighbors;
  int neighborCount;
}

Cell[][] cells;

void setup() {
  size(800, 480);

  background(0);
  noStroke();

  w = ceil(width / cellSize);
  h = ceil(height / cellSize);

  cells = new Cell[w][h];

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = new Cell();

      cell.x = x;
      cell.y = y;
      cell.r = noise(x * .1, y * .1, 0) * 255;
      cell.g = noise(x * .1, y * .1, 1) * 255;
      cell.b = noise(x * .1, y * .1, 2) * 255;
      cell.rNext = cell.r;
      cell.gNext = cell.g;
      cell.bNext = cell.b;
      cell.rVel = 0;
      cell.gVel = 0;
      cell.bVel = 0;
      cell.rVelNext = cell.rVel;
      cell.gVelNext = cell.gVel;
      cell.bVelNext = cell.bVel;
      cell.neighbors = new Cell[4];
      cell.neighborCount = 0;

      cells[x][y] = cell;
    }
  }

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      if (x > 0) {
        cells[x][y].neighbors[0] = cells[x - 1][y];
        cells[x][y].neighborCount += 1;
        cells[x - 1][y].neighbors[2] = cells[x][y];
        cells[x - 1][y].neighborCount += 1;
      }
      if (y > 0) {
        cells[x][y].neighbors[1] = cells[x][y - 1];
        cells[x][y].neighborCount += 1;
        cells[x][y - 1].neighbors[3] = cells[x][y];
        cells[x][y - 1].neighborCount += 1;
      }
    }
  }
}

void draw() {
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = cells[x][y];

      float rAvg = 0;
      float gAvg = 0;
      float bAvg = 0;
      float rVelAvg = 0;
      float gVelAvg = 0;
      float bVelAvg = 0;
      float rSep = 0;
      float gSep = 0;
      float bSep = 0;

      for (int n = 0; n < 4; n++) {
        if (cell.neighbors[n] != null) {
          Cell neighbor = cell.neighbors[n];

          rAvg += neighbor.r;
          gAvg += neighbor.g;
          bAvg += neighbor.b;
          rVelAvg += neighbor.rVel;
          gVelAvg += neighbor.gVel;
          bVelAvg += neighbor.bVel;

          float dr = cell.r - neighbor.r;
          float dg = cell.g - neighbor.g;
          float db = cell.b - neighbor.b;

          // If the color is too close to the neighbor's color, try to steer away from it.
          if (dr * dr  + dg * dg + db * db < minDistSquare) {
            rSep += dr;
            gSep += dg;
            bSep += db;
          }
        }
      }

      rAvg /= cell.neighborCount;
      gAvg /= cell.neighborCount;
      bAvg /= cell.neighborCount;
      rVelAvg /= cell.neighborCount;
      gVelAvg /= cell.neighborCount;
      bVelAvg /= cell.neighborCount;

      // Normalize separation vector to a constant magnitude.
      if (rSep != 0 || gSep != 0 || bSep != 0) {
        float sepNormRecip = sepNormMag / sqrt(rSep * rSep + gSep * gSep + bSep * bSep);
        rSep *= sepNormRecip;
        gSep *= sepNormRecip;
        bSep *= sepNormRecip;
      }

      cell.rVelNext += (rAvg - cell.r + rVelAvg - cell.rVel + rSep) * ease;
      cell.gVelNext += (gAvg - cell.g + gVelAvg - cell.gVel + gSep) * ease;
      cell.bVelNext += (bAvg - cell.b + bVelAvg - cell.bVel + bSep) * ease;

      cell.rNext += cell.rVelNext;
      cell.gNext += cell.gVelNext;
      cell.bNext += cell.bVelNext;

      if (cell.rNext < 0) {
        cell.rNext = 0;
        cell.rVelNext *= -1;
      }
      if (cell.rNext > 255) {
        cell.rNext = 255;
        cell.rVelNext *= -1;
      }
      if (cell.gNext < 0) {
        cell.gNext = 0;
        cell.gVelNext *= -1;
      }
      if (cell.gNext > 255) {
        cell.gNext = 255;
        cell.gVelNext *= -1;
      }
      if (cell.bNext < 0) {
        cell.bNext = 0;
        cell.bVelNext *= -1;
      }
      if (cell.bNext > 255) {
        cell.bNext = 255;
        cell.bVelNext *= -1;
      }
    }
  }

  scale(cellSize);

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = cells[x][y];

      cell.r = cell.rNext;
      cell.g = cell.gNext;
      cell.b = cell.bNext;
      cell.rVel = cell.rVelNext;
      cell.gVel = cell.gVelNext;
      cell.bVel = cell.bVelNext;

      fill(color(cell.r, cell.g, cell.b));
      rect(x, y, 1, 1);
    }
  }
}

void mousePressed() {
  int x = floor(mouseX / cellSize);
  int y = floor(mouseY / cellSize);
  Cell cell = cells[x][y];
  cell.r = 255;
  cell.g = 0;
  cell.b = 0;
  cell.rVel = 0;
  cell.gVel = 0;
  cell.bVel = 0;
}
