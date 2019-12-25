/* Created by: Parinita Edke
 Despcription: A halloween themed game that involves Momo the cat and
 some mean ghosts that stole his spellbook. Draw the respective signs 
 above the ghosts to kill them. Momo loses a life when a ghost touches 
 him. 
 ****USE HEADPHONES TO HEAR COOL SOUND EFFECTS****
 Last edited: Dec 24, 2019
 */

FloatList shapeDrawnX = new FloatList();     //stores all x coordinates of the shape drawn
FloatList shapeDrawnY = new FloatList();     //stores all y coordinates of the shape drawn

float momoWidth = 100;           //width of the cat pic
float momoHeight = 100;          //height of the cat pic

float ghostWidth = 100;          //width of the ghost pic
float ghostHeight = 100;         //height of the ghost pic

int errorMarginLines = 20;      //parameters for vertical and horizontal lines
int lineLength = 20;            //min length of shape drawn to qualify as a line

float maxPositiveSlope = 5;    //max + slope in the arrow
float maxNegativeSlope = -5;    //max - slope in the arrow
float minPositiveSlope = 0.5;    //min + slope in the arrow
float minNegativeSlope = -0.5;    //min - slope in the arrow
int errorMarginArrows = 10;     //parameters for arrows
int minArrowLength = 25;        //min length for drawn shape to qualify as an arrow

Cat tigger;

ArrayList<Ghost> ghostList;
PImage[] lives = new PImage[4];   //ghost lives array (array of size 4 for the 4 different shapes)

PImage momoHeart;
int livesLeft = 9;
int heartXLocation;
int heartYLocation;

int score = 0;
int stopTime = 60;

boolean instructionScreen, gameOver;
PImage night;              //momo pic on instructionScreen
PImage won;                //pic to be displayed on game over if won
PImage lost;              //pic to be displayed on game over if lost

import ddf.minim.*;
AudioPlayer music;
AudioPlayer ding;
AudioPlayer hit;
Minim minim;

void settings() {
  //size(1000, 600);
  fullScreen();
}

void setup() {
  frameRate(60);
  
  tigger = new Cat(width/2, height/2, momoWidth, momoHeight);
  tigger.loadMomoPic();
  
  lives[0] = loadImage("shapes/vertical.png");
  lives[1] = loadImage("shapes/horizontal.png");
  lives[2] = loadImage("shapes/up.png");
  lives[3] = loadImage("shapes/down.png");
  
  // adds the initial ghosts to the game
  ghostList = new ArrayList<Ghost>();
  addGhostsToArray();

  momoHeart = loadImage ("images/heart.png");

  gameOver = false;
  instructionScreen = true;
  night = loadImage("images/night.png");
  won = loadImage("images/End_2.jpg");
  lost = loadImage("images/End_1.jpg");

  minim = new Minim(this);
  music = minim.loadFile("sound_effects/Momo_Cat.mp3");
  ding = minim.loadFile("sound_effects/Ding.mp3");
  hit = minim.loadFile("sound_effects/Hit.mp3");
  music.loop();
}


void draw() {
  if (frameCount%3600 == 0 || livesLeft <= 0) {
    gameOver=true;
  }
  if (gameOver && !instructionScreen) {
    drawGameOverScreen();
  } else if (!instructionScreen && !gameOver ) {
    playGame();
  } else if (instructionScreen && !gameOver) {
    drawInstructionsScreen();
  }
}

void mouseDragged() {
  shapeDrawnX.append(mouseX);     //keep storing all x coordinates
  shapeDrawnY.append(mouseY);     //keep storing all y coordinates
}

void mousePressed() {

  if (instructionScreen) {
    // if the mouse is over the "Start Game" button and is clicked, start the game.
    if (mouseX > 100 && mouseX < 500 && mouseY > height-240 && mouseY < height-140) {
      reset();
      instructionScreen = false;
    }
  }
  
  if (!instructionScreen) {
    // append (x, y) coordinates of the mouse on the game screen.
    shapeDrawnX.append(mouseX);     //store x coordinates
    shapeDrawnY.append(mouseY);     //store y coordinates
  }
  
  // if the game is over and we are not currently on the instructions screen, then
  // if the mouse is over the "Restart Game" button and is clicked, head to the Instructions page.
  if (mouseX > width-200 && mouseY >height-50 && gameOver && !instructionScreen) {
    reset();
    gameOver = false;
    instructionScreen = true;
  }
}

void mouseReleased() {
  if (!instructionScreen)
    if (checkIfVerticalLine() == true) {
      //is a verticle line
      killGhost(0);
    } else if (checkIfHorizontalLine() == true) {
      //is a horizontal line
      killGhost(1);
    } else if (checkIfArrowUp() == true) {
      //arrow facing up
      killGhost(2);
    } else if (checkIfArrowDown() == true) {
      //arrow facing down
      killGhost(3);
    }

  shapeDrawnX.clear();        //clear the XFloatList after drawing the shape
  shapeDrawnY.clear();        //clear the YFloatList after drawing the shape
}

void keyPressed() {
  /* Handles all the keyPressed events. In this particular game, the key presses
  relate to moving Momo arround the screen. Currently supports movement by arrow keys,
  WASD (case insensitive)
 */
  
  int move = 30; //pixels the character can move by
  
  //there is a 40 pixel buffer around the screen to prevent Momo from exiting the screen.
  if (key == CODED || keyPressed) {
    if (keyCode == UP || key == 'w'|| key == 'W') {
      if (tigger.yPos >= 70) { 
        //reduce y coordinate by move
        tigger.yPos -= move;
      }
    } else if (keyCode == DOWN || key == 's'|| key == 'S') {
      if (tigger.yPos <= height-70) { 
        //increase y coordinate by move
        tigger.yPos += move;
      }
    } else if (keyCode == RIGHT|| key == 'd'|| key == 'D') {
      if (tigger.xPos <= width-70) { 
        //increase x coordinate by move
        tigger.xPos +=move;
      }
    } else if (keyCode == LEFT|| key == 'a'|| key == 'A') {
      if (tigger.xPos >= 70) { 
        //decrease x coordinate by move
        tigger.xPos -= move;
      }
    }
  }
}


boolean checkIfVerticalLine() {
  /* Checks if the points created by shapeDrawnX and shapeDrawnY form a vertical line.
  There is an error margin of +- errorMarginLines pixels.
 */
  for (int i = 1; i < shapeDrawnX.size(); i++) {
    if (shapeDrawnX.get(i) > (shapeDrawnX.get(0) + errorMarginLines) || shapeDrawnX.get(i) < (shapeDrawnX.get(0)-errorMarginLines)) {
      return false;
      //if x coordinates are greater or less than the first x value+-errorMargin,
      //then return false
    }
  }
  if ((shapeDrawnY.get(shapeDrawnY.size() - 1) - shapeDrawnY.get(0)) < lineLength) {
    return false;
    //if the shape drawn is less than line length, then return false
  }
  return true;
}

boolean checkIfHorizontalLine() {
    /* Checks if the points created by shapeDrawnX and shapeDrawnY form a horizontal line.
  There is an error margin of +- errorMarginLines pixels.
 */
  for (int i = 1; i < shapeDrawnY.size(); i++) {
    if (shapeDrawnY.get(i) > (shapeDrawnY.get(0) + errorMarginLines)|| shapeDrawnY.get(i)< (shapeDrawnY.get(0)-errorMarginLines)) {
      return false;
      //if y coordinates are greater or less than the first y value+-errorMargin,
      //then return false
    }
  }
  if ((shapeDrawnX.get(shapeDrawnX.size() - 1) - shapeDrawnX.get(0)) < lineLength) {
    return false;
    //if the shape drawn is less than line length, then return false
  }
  return true;
}

boolean checkIfArrowUp() {
    /* Checks if the points created by shapeDrawnX and shapeDrawnY form an upwards arrow.
    */
  
  float maxYValue = shapeDrawnY.min(); //top of arrow
  int maxYValueIndex = valueIndex(maxYValue, shapeDrawnY); //index at which top value occurs
  float maxXValue = shapeDrawnX.get(maxYValueIndex); //x-value of the topmost point
  float slope1 = (maxYValue - shapeDrawnY.get(0))/(maxXValue - shapeDrawnX.get(0));
  float slope2 = (maxYValue - shapeDrawnY.get(shapeDrawnY.size()-1))/(maxXValue - shapeDrawnX.get(shapeDrawnX.size()-1));

  float x1;
  float x2;
  float y1;
  float y2;
  float x0;
  float y0;
  float dist;
  float d;

  if (slope1 > maxPositiveSlope) {
    return false;
  } else if (slope1 < minPositiveSlope && slope1 > minNegativeSlope) {
    return false;
  } else if (slope1 < maxNegativeSlope) {
    return false;
    //The arrow is divided into two lines at the top most point of the
    //upwards arrow. The slope of the lines have to be within a certain 
    //limit so as to prevent players from drawing steep slopes or
    //vertical lines, as vertical lines can be considered as a 'slope'.
  }
  x1 = shapeDrawnX.get(0);
  y1 = shapeDrawnY.get(0);
  x2 = shapeDrawnX.get(maxYValueIndex);
  y2 = maxYValue; 
  dist = dist(x1, y1, x2, y2);
  //dist of the first arrow leg

  if (dist < minArrowLength) {
    return false;
    //if length of one arrow leg is less than minArrowLength,
    //then return false
  }

  for (int i = 1; i < maxYValueIndex; i++) {
    x0 = shapeDrawnX.get(i);
    y0 = shapeDrawnY.get(i);
    d = abs((y2 - y1)*x0 -(x2 - x1)* y0 + x2 * y1 - y2 * x1)/dist;
    if (d > errorMarginArrows) {
      return false;
      //if distance of points from the average line is greater than 
      //errorMarginArrows, return false
    }
  }



  if (slope2 > maxPositiveSlope) {
    return false;
  } else if (slope2 < minPositiveSlope && slope2 > minNegativeSlope) {
    return false;
  } else if (slope2<  maxNegativeSlope) {
    return false;
    //The arrow is divided into two lines at the top most point of the
    //upwards arrow. The slope of the lines have to be within a certain 
    //limit so as to prevent players from drawing steep slopes or
    //vertical lines, as vertical lines can be considered as a 'slope'.
  }

  x1 = shapeDrawnX.get(shapeDrawnX.size()-1);
  y1 = shapeDrawnY.get(shapeDrawnY.size()-1);
  x2 = shapeDrawnX.get(maxYValueIndex);
  y2 = maxYValue; 
  dist = dist(x1, y1, x2, y2);
  //dist of the second arrow leg

  if (dist < minArrowLength) {
    return false;
  }

  for (int i = maxYValueIndex + 1; i < shapeDrawnY.size(); i++) {
    x0 = shapeDrawnX.get(i);
    y0 = shapeDrawnY.get(i);
    d = abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1)/dist;
    if (d > errorMarginArrows) {
      return false;
      //if distance of points from the average line is greater than 
      //errorMarginArrows, return false
    }
  }
  return true;
}

boolean checkIfArrowDown() {
   /* Checks if the points created by shapeDrawnX and shapeDrawnY form a downwards arrow.
    */
  float minYValue = shapeDrawnY.max(); //bottom of arrow
  int minYValueIndex = valueIndex(minYValue, shapeDrawnY); //index at which bottom value occurs
  float minXValue = shapeDrawnX.get(minYValueIndex); //x-value of the lowest point
  float slope1 = (minYValue - shapeDrawnY.get(0))/(minXValue - shapeDrawnX.get(0));
  float slope2 = (minYValue - shapeDrawnY.get(shapeDrawnY.size() - 1))/(minXValue - shapeDrawnX.get(shapeDrawnX.size()-1));

  float x1;
  float x2;
  float y1;
  float y2;
  float x0;
  float y0;
  float dist;
  float d;

  if (slope1 > maxPositiveSlope) {
    return false;
  } else if (slope1 < minPositiveSlope && slope1 > minNegativeSlope) {
    return false;
  } else if (slope1 < maxNegativeSlope) {
    return false;
    //The arrow is divided into two lines at the lowest point of the
    //downwards arrow. The slope of the lines have to be within a certain 
    //limit so as to prevent players from drawing steep slopes or
    //vertical lines, as vertical lines can be considered as a 'slope'.
  }

  x1 = shapeDrawnX.get(0);
  y1 = shapeDrawnY.get(0);
  x2 = shapeDrawnX.get(minYValueIndex);
  y2 = minYValue; 
  dist = dist(x1, y1, x2, y2);
  //dist of the first arrow leg

  if (dist < minArrowLength) {
    return false;
  }

  for (int i = 1; i < minYValueIndex; i++) {
    x0 = shapeDrawnX.get(i);
    y0 = shapeDrawnY.get(i);
    d = abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1)/dist;
    if (d > errorMarginArrows) {
      return false;
      //if distance of points from the average line is greater than 
      //errorMarginArrows, return false
    }
  }

  if (slope2 > maxPositiveSlope) {
    return false;
  } else if (slope2 < minPositiveSlope && slope2 > minNegativeSlope) {
    return false;
  } else if (slope2 < maxNegativeSlope) {
    return false;
    //The arrow is divided into two lines at the lowest point of the
    //downwards arrow. The slope of the lines have to be within a certain 
    //limit so as to prevent players from drawing steep slopes or
    //vertical lines, as vertical lines can be considered as a 'slope'.
  }
  x1 = shapeDrawnX.get(shapeDrawnX.size()-1);
  y1 = shapeDrawnY.get(shapeDrawnY.size()-1);
  x2 = shapeDrawnX.get(minYValueIndex);
  y2 = minYValue; 
  dist = dist(x1, y1, x2, y2);
  //dist of the second arrow leg

  if (dist < minArrowLength) {
    return false;
  }

  for (int i = minYValueIndex + 1; i < shapeDrawnY.size(); i++) {
    x0 = shapeDrawnX.get(i);
    y0 = shapeDrawnY.get(i);
    d = abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1)/dist;
    if (d > errorMarginArrows) {
      return false;
      //if distance of points from the average line is greater than 
      //errorMarginArrows, return false
    }
  }
  return true;
}

int valueIndex(float value, FloatList list) {
  for (int i = 0; i < list.size(); i++) {
    if (value == list.get(i)) {
      return i;
    }
  }
  return -1;
}

void drawArc(FloatList X, FloatList Y) {
   /* Draws the actual line the player makes with the mouse on the screen.
    */
  if (X.size() > 0) {
    strokeWeight(5);
    stroke(0, 255, 0);
    point(X.get(0), Y.get(0));
    for (int i = 0; i < X.size()-1; i++) {
      line(X.get(i), Y.get(i), X.get(i+1), Y.get(i+1));
    }
  }
}


void addGhostsToArray() {
   /* Adds 4 ghosts to the game to chase Momo.
    */
  float randHeight;
  float randWidth;
  Ghost casper;

  for (int i = 0; i < 4; i++) { 
    while (true) {
      randHeight = random(height);
      randWidth = random(width);
      if (dist(randHeight, randWidth, tigger.xPos, tigger.yPos) >= 400) {
        break;
        //if the dist is >= 400, break out of the for loop and add the 
        //ghost to the array
      }
    }
    casper = new Ghost(randWidth, randHeight, ghostWidth, ghostHeight);
    ghostList.add(casper);
  }
}

void killGhost(int particularGhost) {
   /* Checks if the shape drawn by the player matches any of the ghosts. If yes, add
   10 points to the player's score.
    */
  for (int i = (ghostList.size()-1); i >=0 ; i--) {
    if ((ghostList.get(i).ghostLife) == particularGhost) {
      //check if the life of a ghost in the 
      //array have a certain value. If yes,
      //remove the ghost.
      ghostList.remove(i);
      score += 10;
      ding.rewind();
      ding.play();
    }
  }
}

boolean momoGetsHurt() {
   /* Checks if Momo gets hurt by the ghosts if they get too close to him.
    */
  for (int i = (ghostList.size() - 1); i >= 0; i--) {
    float d = dist(tigger.xPos, tigger.yPos, ghostList.get(i).pos.x, ghostList.get(i).pos.y);
    if (d < 90) {//if distance between Momo and the ghost if less than 90, take a life of Momo
      return true;
    }
  }
  return false;
}


void drawInstructionsScreen() {
   /* Draws the instructions screen. */
  int imageWidth = 600;
  int imageHeight = 400;

  background(255);
  imageMode(CENTER);
  image(night, width/2 + 400, height/2 + 200, imageWidth, imageHeight);
  textSize(30);
  fill(0);
  textAlign(LEFT);//HUH?? HOW DOES THIS AFFECT MY TIMER??
  text("OH NO! Momo the cat has lost his spellbook!\n" + "Help him get it back by destroying the ghosts.\n"+"\n"+"Draw the respective signs above the ghosts to gain points.\n"+"To draw, press the mouse and draw the shape, then release the mouse when done.\n"+"Hurry because you lose lives if the ghosts touch you.\n"+"Use the arrow keys or WASD to move around!\n" +"You get 10 points per ghost killed.\n"+"\n"+"Click on the button to start the game! GOOD LUCK!", 100, 100);
  text("Game Creator: Parinita Edke", 100, height - 50);
  reset();

  fill(237, 10, 10);
  stroke(0);
  rect(100, height - 240, 400, 100);
  textSize(50);
  fill(255);
  text("START GAME", 145, height - 170);
}

void drawGameOverScreen() {
  /* Draws the game over screen. */
  int imageWidth = 400;
  int imageHeight = 250;

  background(255);
  textAlign(CENTER);
  fill(0);
  textSize(70);
  text("GAME OVER", width/2, height/4);
  textSize(30);
  text("Your Score =" + score, width/2, height/4 + 50);

  if (score == 0 || livesLeft == 0) {
    text("Momo lost his spellbook :( Try again next time", width/2, height/2);
    imageMode(CENTER);
    image(lost, width/2, height/2+150, imageWidth, imageHeight);
  } else if (score > 0 &&livesLeft > 0) {
    text("Thanks for helping Momo get his spellbook back!", width/2, height/2);
    imageMode(CENTER);
    image(won, width/2, height/2 + 150, imageWidth, imageHeight);
  }

  rectMode(CORNER); //this is my restart button
  fill(255, 0, 0);
  rect(width - 200, height - 50, 200, 50);
  fill(255);
  text("RESTART", width - 100, height - 15);
  textAlign(LEFT);
}

void reset() {
  /* Resets the settings of the game. Score becomes 0, timer sets back to 60 seconds and 
  Momo has 9 lives again. */
  score = 0;
  stopTime = 60;
  livesLeft = 9;
  frameCount = 0;
}

void playGame() {
  /* Starts the game. */
  heartXLocation = 30;
  heartYLocation = 30;

  background(255); 
  stopTime = 60 - int(frameCount/60); //this is /60 because Processing defaults to 60 frames per second
  textSize(70);
  fill(0);
  text(stopTime, width - 100, 70);
  fill(0);
  textSize(30);
  text("Score:" + score, heartXLocation - 5, 80);

  tigger.drawMomo();
  drawArc(shapeDrawnX, shapeDrawnY);

  for (int i = (ghostList.size() - 1); i >= 0; i--) {
    if (ghostList.size() > 0) { //if there are ghosts in the array, 
      ghostList.get(i).drawGhost(); //draw and update them
      ghostList.get(i).updateGhost();
    } 
    if (momoGetsHurt() == true) {
      ghostList.remove(i); //remove the ghost that touches Momo
      livesLeft -= 1;        //take a life of Momo
      hit.rewind();
      hit.play();
    }
  }
  if (ghostList.size() == 0) {
    addGhostsToArray();    //if array is empty, add another array of 4 ghosts
  }

  for (int i = 0; i < livesLeft; i++) { 
    image(momoHeart, heartXLocation, heartYLocation, 20, 20);
    heartXLocation += 30;
    //draws Momo's lives on the top left corner of the screen
  }
}
