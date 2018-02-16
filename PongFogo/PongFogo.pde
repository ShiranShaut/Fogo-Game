import processing.sound.*;

class Point
{
  Point(float xx, float yy, float red, float green, float blue, int bri)
  {
    x=xx; y=yy; r=red; g=green; b=blue; 
    colo = color(r,g,b); 
    shapeBright = bri;
  }
  float x,y;
  float r,g,b;
  color colo;
  int shapeBright;
};

SoundFile hit_collision, hit_wall, sound_fail;
float ballX, ballY, ballR, dX, dY;
float paddle1X, paddle1Y=10, paddle1W=20, paddle1H=190;
float paddle2X, paddle2Y=10, paddle2W=20, paddle2H=190;
ArrayList<Point> ourList = new ArrayList<Point>();
boolean isLeft, isRight, isUp, isDown; 
boolean pauseFlag=false, gameStarted=false;
PShape paddle1, paddle2, Ball;
PImage openScreen, gameScreen, gameOver;
float red=0, green=0, blue=0;
int bright=150, lastCounter=0, record=0;
boolean paddle1_hit=false, paddle2_hit=false, failFlag = false;
String S_record = "Record: ", S_hits = "Hits: ";

void setup()
{
  // Sounds Effects
  hit_collision = new SoundFile(this, "hit_collision.mp3");
  hit_wall = new SoundFile(this, "hit_wall.mp3");
  sound_fail = new SoundFile(this, "add_fail.mp3");
  size(1280, 720);
  strokeWeight(11);
  
  //Images
  openScreen = loadImage("openscreen.jpg");
  gameScreen = loadImage("gamescreen.jpg");
  paddle1 = loadShape("paddle1.svg");
  paddle2 = loadShape("paddle2.svg");
  Ball = loadShape("ball2.svg"); 
  gameOver = loadImage("gameover.jpg");
 
  ballX = width/2;
  ballY = height/2;
  ballR = 15;
 
  dX = random(3.0, 3.7); //Starting SPEED
  dY = random(3.0, 3.7); //Starting SPEED
  paddle1X = width-21;
  paddle2X = 0;
  red = random(0,255);
  blue = random(0,255);
  green = random(0,255);
}

void restart() {
  pauseFlag = false;
  gameStarted = true;
  failFlag = false;;
  bright = 150;
 // if (record < lastCounter) // new record
  record = lastCounter;
  lastCounter = 0;
  background(gameScreen);
  ourList.clear();
  dX = random(3.0, 3.7); //Starting SPEED
  dY = random(3.0, 3.7); //Starting SPEED
}

void fail() {
  bright -= 50;
  for(int i=0; i<ourList.size()-1; i++)
  {
    ourList.get(i).shapeBright = bright;
  }
  ballX = width/2;
  ballY = height/2;
  ballR = 15;
}

void fail_the_game() {
  background(gameOver);
  ourList.clear();
  failFlag = true;
  hit_collision.stop();
  hit_wall.stop();
}

void draw()
{ 
  if (pauseFlag == false && gameStarted == false)
  {   background(openScreen);   }
  else
  {
    background(gameScreen);
    shape(Ball, ballX-ballR, ballY-ballR, 2*ballR, 2*ballR);
    shape(paddle1, paddle1X, paddle1Y, paddle1W, paddle1H);
    shape(paddle2, paddle2X, paddle2Y, paddle2W, paddle2H);

    if(ballRight() > width) // fail
    {
      if(bright == 50) // fail #3 - will fail the game
      { fail_the_game(); }
      else
      { fail(); }
    }
     
    if(ballLeft() < 0) // fail
    {
      if(bright == 50) // fail #3 - will fail the game
      { fail_the_game(); }
      else
      { fail(); }
    }
  
  if (collision()) 
  {
    lastCounter++;
    if(record < lastCounter) { record++; }

    if(paddle1_hit)
    {
      paddle1_hit = false;
      dX += 0.1;
      dX = -dX;
      if (ballY <= paddle1Y/2 && ballX <= paddle1Y)
      { dY -= random(0,1.5); }
      if (ballY >= paddle1Y/2 && ballX >= paddle1Y)
      { dY += random(0,1.5); }
    }
   
    if(paddle2_hit)
    {
      paddle2_hit = false;
      dX += 0.1;
      dX = -dX;
      if (ballY <= paddle2Y/2 && ballX <= paddle2Y)
      { dY -= random(0,1.5); }
      if (ballY >= paddle2Y/2 && ballX >= paddle2Y)
      { dY += random(0,1.5); }
     }
     
     red = random(0,255);
     blue = random(0,255);
     green = random(0,255); 
    } 
    
    if(ballY > height)
    {
      dY = -dY;
      hit_wall.play();
    } // if dY == 2, it becomes -2; if dY is -2, it becomes 2
    if(ballTop() < 0)
    {
      dY = -dY;
      hit_wall.play();
    }
  
    ballX += dX;
    ballY += dY; 
   
   if((frameCount%4)==0)
   { savePoint(ballX, ballY); }
   
   for(int i=0; i<ourList.size(); ++i)
   {
     stroke(ourList.get(i).colo, ourList.get(i).shapeBright);
     point(ourList.get(i).x, ourList.get(i).y);
   }
 
   if (isLeft)
   {
     if(paddle2Y <= height - paddle2H)
     { paddle2Y = paddle2Y + paddle2H * 0.045; }
   }
   if (isRight)
   {
     if (paddle2Y >= 0) 
     { paddle2Y = paddle2Y - paddle2H * 0.045; }
   }
   if (isDown)
   {
     if(paddle1Y <= height - paddle1H)
     { paddle1Y = paddle1Y + paddle1H * 0.045; }
   }
   if (isUp)
   {
     if (paddle1Y >= 0) 
     { paddle1Y = paddle1Y - paddle1H * 0.045; }
   }
     
   textSize(50);
   text(S_hits + lastCounter, width/2+250 , 70);
   text(S_record + record, width/2-450 , 70);
 } //end of else
} //end of draw

void savePoint(float x, float y)
{
   ourList.add(new Point(x,y,red,green,blue,200));
}

boolean collision()
{
  boolean returnValue = false; // assume there is no collision
  if((ballRight() >= paddle1X) && (ballLeft() <= paddle1X + paddle1W))
  {
    if((ballY >= paddle1Y) && (ballTop() <= paddle1Y + paddle1H))
    {
      paddle1_hit = true;
      returnValue = true;
      hit_collision.play();
    }
  }
  
  if((ballLeft() <= paddle2X+15) && (ballRight() >= paddle2X + paddle2W))
  {
    if((ballY >= paddle2Y) && (ballTop() <= paddle2Y + paddle2H))
    {
      paddle2_hit = true;
      returnValue = true;
      hit_collision.play();
    }
  }
  return returnValue;
}

//Ball's Moves
float ballLeft()
{ return ballX-ballR; }

float ballRight()
{ return ballX + ballR; }

float ballTop()
{ return ballY - ballR; }

float ballBottom()
{ return ballY + ballR; }

void keyPressed() 
{
 if (key == 'p' || key == 'P')
   {
     if(pauseFlag == false)
     {
       if(gameStarted == false)
       { gameStarted = true; }
       else // when game is paused
       {
         if(failFlag == false)
         {
            noLoop();
            textSize(50);
            text("Game Paused", width/2 -width/2/4 , height/2);
            pauseFlag = true;
         }
         if (failFlag == true)
         {
           pauseFlag = true;
           restart();
         }
       }    
     }
     else // p after pause station - start
     {  
       pauseFlag = false;
       loop();
     }
   }
  else
   { setMove(keyCode, true); }
}
 
void keyReleased() 
{
  setMove(keyCode, false);
}
 
boolean setMove(int k, boolean b) 
{
  switch (k) 
  {
  case UP:
    return isUp = b;
 
  case DOWN:
    return isDown = b;
 
  case LEFT:
    return isLeft = b;
 
  case RIGHT:
    return isRight = b;
 
  default:
    return b;
  }
}