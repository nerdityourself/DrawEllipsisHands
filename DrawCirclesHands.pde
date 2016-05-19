import SimpleOpenNI.*;

SimpleOpenNI  context;
// Points for right hand
PVector hand_r_real = new PVector();
PVector hand_r_calc = new PVector();
// Point for left hand
PVector hand_l_real = new PVector();
PVector hand_l_calc = new PVector();
// x and y values for ellipses
float x_ellipse_l = 0;
float y_ellipse_l = 0;
float x_ellipse_r = 0;
float y_ellipse_r = 0;
// Flag indicating if will use colored or balck and white ellipses
boolean colored = false;
// Speed of following
float easing = 0.03;
float x = 100;
float y = 100;
// Variables ofr bezier drawing
int indexCurveLeft = 0;
int indexCurveRight = 0;
// Mouse used for test and debug
PVector mouse = new PVector(mouseX,mouseY);

void setup()
{

  // size(1100,700,P3D);
  //size(1900,1000,P3D);
  // Set dimensions of the canvas.
   size(displayWidth - 50, displayHeight - 100);

  // Init SimpleOpenNI object
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
  // enable skeleton generation for all joints
  context.enableUser();
 
  //background(255,255,255);
  background(0,0,0);
  if(colored)
    colorMode(HSB, height, height, height); 
 
  stroke(255,0,0);
  strokeWeight(3);
  smooth(8);
}


void draw(){
 
  translate(150,-50);

  // stroke(0,20);
  //  stroke(21, 95, 142);
  stroke(255,255,255);
  // update the cam
  context.update();
  // Check id there is an user
  int[] userList = context.getUsers();
  for(int i=0; i < userList.length; i++)
  {
    
    // In this example we manage only one user, so we execute the following code only for i == 0
    if(i == 0)
    {
        if(context.isTrackingSkeleton(userList[i]))
        {
              // Uncomment the folowing line if you want to draw the skeleton
              // drawSkeleton(userList[i]); 
            
              // Get right hand coordinates
              context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND,hand_r_real);
              context.convertRealWorldToProjective(hand_r_real,hand_r_calc);
              // Get left hand coordinates
              context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_LEFT_HAND,hand_l_real);
              context.convertRealWorldToProjective(hand_l_real,hand_l_calc);
          
             if(!Float.isNaN(hand_r_calc.x) && !Float.isNaN(hand_r_calc.y)) // Be scure that we have good coordinates
             {
               hand_r_calc.y = map(hand_r_calc.y, 77, 420, 0, 1000); //699
               hand_r_calc.x = map(hand_r_calc.x, 120, 570, 0, 1900); //1097
               // Now draw ellipse for right hand
               lineEllipseRight(hand_r_calc.x, hand_r_calc.y);
             }
           
            if(!Float.isNaN(hand_l_calc.x) && !Float.isNaN(hand_l_calc.y)) // Be scure that we have good coordinates
             {
                 hand_l_calc.y = map(hand_l_calc.y, 77, 420, 0, 1000);
                 hand_l_calc.x = map(hand_l_calc.x, 120, 570, 0, 1900);
                 // Now draw ellipse for left hand
                 lineEllipseLeft(hand_l_calc.x, hand_l_calc.y);
             }
       }

  }
 }
}



void keyPressed()
{
  // Press a key if you want to clear the canvas
  background(255);
  delay(3000);
}  


// -----------------------------------------------------------------
// Drawing methods

void lineEllipseLeft(float hx, float hy)
{
 
  // If it is the first time we enter in this function x value for the center of the ellipse is the x value of the hand
  if(x_ellipse_l == 0)
    x_ellipse_l = hx;
    
  // If it is the first time we enter in this function x value for the center of the ellipse is the x value of the hand
  if(y_ellipse_l == 0)
    y_ellipse_l = hy;
    
  float targetX = hx;
  float dx = targetX - x_ellipse_l; // dx is the difference between the previus x value of the center and the new x value
  x_ellipse_l += dx * easing; // Add to the previous x value of the center dx * easing

  float targetY = hy;
  float dy = targetY - y_ellipse_l;
  y_ellipse_l += dy * easing;

  ellipse( x_ellipse_l, y_ellipse_l, 30, 30);
  fill(0, 0, 0);
}


void lineEllipseRight(float hx, float hy)
{
  
  if(x_ellipse_r == 0)
    x_ellipse_r = hx;
    
  if(y_ellipse_r == 0)
    y_ellipse_r = hy;
  
  float targetX = hx;
  float dx = targetX - x_ellipse_r;
  x_ellipse_r += dx * easing;

  float targetY = hy;
  float dy = targetY - y_ellipse_r;
  y_ellipse_r += dy * easing;

  ellipse( x_ellipse_r, y_ellipse_r, 30, 30 );
  fill(0, 0, 0);
  if(colored)
   fill(y_ellipse_r, height, height);
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  //background(255,255,255);
}


// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

