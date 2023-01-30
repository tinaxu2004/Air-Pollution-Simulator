// Tina Xu
// October 23, 2021
// ICS4UI - Mr. Schattman

//Change those variables
int n = 100; // Size of the grid (100 x 100 is recommended)
float blinksPerSecond = 10; // Speed of the animation
float pad = 20; // Padding
boolean isRunning = false; // Simulation running status
float percentPeople = 0.1; // Percentage of people on land (default: 10%)
float percentCleanAir = 0.7; // Percentage of clean air on land (default: 70%)
float pollutantsChance = 0.9; // Probability of pollutant spawning beside a factory (default: 80%)
float chanceBecomingPollutant = 0.5; // Probability of clean air becoming pollutant

//Do not change those variables
float cellSize; // Size of each cell
color cells[][] = new color[n][n];
color cellsNext[][] = new color[n][n]; 
float numPeople = percentPeople * n * n; // Number of human cells
float numCleanAir = percentCleanAir * n * n; // Number of clean air cells

color factory = color(0); // Factory - black 
color pollutant = color(128); // Pollutant - grey 
color cleanAir = color(255); // Clean air - white 
color human1 = color(50, 205, 50);   // Healthy person - green
color human2 = color(0, 102, 204);   // Slightly sick person - blue
color human3 = color(255, 102, 102); // Severely sick person - red
color land = color(222, 184, 135); // Land - tan/yellow

void setup() {
  size(1080, 650);
  frameRate(blinksPerSecond);
  cellSize = (width - 2 * pad) / n;
  setCellValuesRandomly();
  noLoop();
}

void mousePressed() { // Press to START simulation
  if (isRunning) {
    noLoop();
    isRunning = false;
  } else {
    loop();
    isRunning = true;
  }
}

void draw() {
  background(225, 255, 0);
  float y = pad;

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      float x = j * cellSize + pad;

      fill(cells[i][j]);
      stroke(cells[i][j]);

      rect(x, y, cellSize, cellSize);
      x += cellSize;
    }
    y += cellSize;
  }
  
  setNextGen();
  copyNextGen();
}

void setCellValuesRandomly() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (j == n - 1)
        cells[i][j] = factory;
      else
        cells[i][j] = land;
    }
  }

  while (numPeople > 0) {
    int randomRow1 = round(random(0, n - 1));
    int randomCol1 = round(random(0, n - 2));
    if (cells[randomRow1][randomCol1] == land)
      cells[randomRow1][randomCol1] = human1;
    numPeople--;
  }

  while (numCleanAir > 0) {
    int randomRow2 = round(random(0, n - 1));
    int randomCol2 = round(random(0, n - 2));
    if (cells[randomRow2][randomCol2] == land)
      cells[randomRow2][randomCol2] = cleanAir;
    numCleanAir--;
  }
}

void setNextGen() {
  spawnPollutant();
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      int numCleanAir = countCleanAir(i, j);
      int numPollutants = countPollutants(i, j);
      color type = cells[i][j];

      if (j == n - 1)
        cellsNext[i][j] = factory;
      else if (type == pollutant) {
        if (numCleanAir >= 3)
          cellsNext[i][j] = cleanAir;
        else
          cellsNext[i][j] = pollutant;
      } else if (type == cleanAir) {
        if (numPollutants >= 3)
          cellsNext[i][j] = pollutant;
        else
          cellsNext[i][j] = cleanAir;
      } else if (type == human1) { // healthy - no pollutants
        if (numPollutants == 0)
          cellsNext[i][j] = human1;
        else if (numPollutants == 1 || numPollutants == 2)
          cellsNext[i][j] = human2;
        else if (numPollutants == 3)
          cellsNext[i][j] = human3;
      } else if (type == human2) { // slightly sick
        if (numPollutants >= 2)
          cellsNext[i][j] = human3;
        else
          cellsNext[i][j] = human2;
      } else if (type == human3) { //very sick
        if (numPollutants > 1 || numPollutants == 1 && random(1) > 0.75)
          cellsNext[i][j] = land;
      } else 
      cellsNext[i][j] = land;
    }
  }
  moveHuman();
  movePollutant();
  moveCleanAir();
}

void spawnPollutant() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      float prob = random(1);
      if (pollutantsChance >= prob && cellsNext[i][n - 1] == factory) // spawn on the left of factory
        cells[i][n - 2] = pollutant;
    }
  }
}

void moveHuman() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      int sX = round(random(-1, 1)); // current speed x
      int sY = round(random(-1, 1)); // current speed y

      int iNext = i + sY;
      int jNext = j + sX;

      color type = cellsNext[i][j];
      try {
        if (isHuman(type) && (sX != 0 || sY != 0) && cellsNext[iNext][jNext] == land) {
          cellsNext[iNext][jNext] = type;
          cellsNext[i][j] = land;

          if (cellsNext[iNext][jNext] == pollutant) { // human consumed pollutants
            if (type == human1)
              cellsNext[iNext][jNext] = human2;
            else if (type == human2)
              cellsNext[iNext][jNext] = human3;
            else if (type == human3)
              cellsNext[iNext][jNext] = land;
          }
        } else {
          cellsNext[i][j] = type;
        }
      } 
      catch (Exception e) {
      }
    }
  }
}

void movePollutant() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      int sX = round(random(-2, 1)); // current speed x
      int sY = round(random(-1, 1)); // current speed y

      int iNext = i + sY;
      int jNext = j + sX;

      color type = cellsNext[i][j];
      try {
        if (type == pollutant && (sX != 0 || sY != 0) && cellsNext[iNext][jNext] != pollutant &&
          cellsNext[iNext][jNext] != factory) {
          if (isHuman(cellsNext[iNext][jNext])) { // human consumed pollutants
            if (type == human1)
              cellsNext[iNext][jNext] = human2;
            else if (type == human2)
              cellsNext[iNext][jNext] = human3;
            else if (type == human3)
              cellsNext[iNext][jNext] = land;
          } else {
            cellsNext[iNext][jNext] = pollutant;
          }
          cellsNext[i][j] = land;
        } else {
          cellsNext[i][j] = type;
        }
      } 
      catch (Exception e) {
      }
    }
  }
}

void moveCleanAir() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      int sX = round(random(-1, 1)); // current speed x
      int sY = round(random(-1, 1)); // current speed y

      int iNext = i + sY;
      int jNext = j + sX;

      color type = cellsNext[i][j];
      try {
        if (type == cleanAir && (sX != 0 || sY != 0) && cellsNext[iNext][jNext] == land) {
          cellsNext[iNext][jNext] = type;

          if (cellsNext[iNext][jNext] == pollutant) { //clean air become pollutant
            float prob = random(1);
            if (chanceBecomingPollutant >= prob)
              cellsNext[iNext][jNext] = type;
          }
          cellsNext[i][j] = land;
        } else {
          cellsNext[i][j] = type;
        }
      } 
      catch (Exception e) {
      }
    }
  }
}

void copyNextGen() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      cells[i][j] = cellsNext[i][j];
    }
  }
}

int countPollutants(int i, int j) {
  int count = 0;
  for (int a = -1; a < 1; a++) {
    for (int b = -1; b < 1; b++) {
      try {
        if (cells[i + a][j + b] == pollutant && (a != 0 || b != 0))
          count++;
      } 
      catch (Exception e) {}
    }
  }
  return count;
}

int countCleanAir(int i, int j) {
  int count = 0;
  for (int a = -1; a < 1; a++) {
    for (int b = -1; b < 1; b++) {
      try {
        if (cells[i + a][j + b] == cleanAir && (a != 0 || b != 0))
          count++;
      } 
      catch (Exception e) {}
    }
  }
  return count;
}

boolean isHuman(color currentCell) {
  boolean isTrue = (currentCell == human1 || currentCell == human2 || currentCell == human3);
  return isTrue;
}
