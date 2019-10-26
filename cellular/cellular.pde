// adapted from http://rectangleworld.com/blog/archives/587

float cellSize = 10;
int w;
int h;

float ease = 0.5;
float minDist = 8;
float minDistSquare = minDist * minDist;
float sepNormMag = 4;
float clickMag = 100;

class Cell {
  int x;
  int y;
  PVector col;
  PVector colNext;
  PVector vel;
  PVector velNext;
  Cell[] neighbors;
  int neighborCount;
}

Cell[][] cells;

void setup() {
  size(800, 480);
  noStroke();

  w = ceil(width / cellSize);
  h = ceil(height / cellSize);

  cells = new Cell[w][h];

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = new Cell();

      cell.x = x;
      cell.y = y;
      cell.col = new PVector(
        noise(x * .1, y * .1, 0) * 255,
        noise(x * .1, y * .1, 1) * 255,
        noise(x * .1, y * .1, 2) * 255);
      cell.colNext = cell.col.copy();
      cell.vel = new PVector(0, 0, 0);
      cell.velNext = cell.vel.copy();
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
  background(0);
  scale(cellSize);

  int mx = floor(mouseX / cellSize);
  int my = floor(mouseY / cellSize);

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = cells[x][y];

      PVector colAvg = new PVector(0, 0, 0);
      PVector velAvg = new PVector(0, 0, 0);
      PVector sep = new PVector(0, 0, 0);

      for (int n = 0; n < 4; n++) {
        if (cell.neighbors[n] != null) {
          Cell neighbor = cell.neighbors[n];

          colAvg.add(neighbor.col);
          velAvg.add(neighbor.vel);
          PVector dist = PVector.sub(cell.col, neighbor.col);

          // If the color is too close to the neighbor's color, try to steer away from it.
          if (dist.magSq() < minDistSquare) {
            sep.add(dist);
          }
        }
      }

      colAvg.div(cell.neighborCount);
      velAvg.div(cell.neighborCount);

      // Normalize separation vector to a constant magnitude.
      if (sep.magSq() > 0) {
        sep.setMag(sepNormMag);
      }

      cell.velNext.lerp(velAvg.add(colAvg).sub(cell.col).add(sep), ease);
      // cell.velNext.add(PVector.add(colAvg, velAvg).sub(cell.col).sub(cell.vel).add(sep).mult(ease));
      cell.colNext.add(cell.velNext);

      // Bounce velocity if color values go out of bounds.
      cell.velNext.set(
        (cell.colNext.x < 0 || cell.colNext.x > 255) ? -cell.velNext.x : cell.velNext.x,
        (cell.colNext.y < 0 || cell.colNext.y > 255) ? -cell.velNext.y : cell.velNext.y,
        (cell.colNext.z < 0 || cell.colNext.z > 255) ? -cell.velNext.z : cell.velNext.z);
      // Constrain the color values.
      cell.colNext.set(
        constrain(cell.colNext.x, 0, 255),
        constrain(cell.colNext.y, 0, 255),
        constrain(cell.colNext.z, 0, 255));

      // Use mouse input to mess with the colors.
      if (mousePressed && x == mx && y == my) {
        // cell.colNext.set(255 - cell.colNext.x, 255 - cell.colNext.y, 255 - cell.colNext.z);
        cell.velNext.setMag(clickMag);
      }
    }
  }

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      Cell cell = cells[x][y];

      cell.col.set(cell.colNext);
      cell.vel.set(cell.velNext);

      fill(color(cell.col.x, cell.col.y, cell.col.z));
      rect(x, y, 1, 1);
    }
  }
}
