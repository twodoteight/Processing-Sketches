PImage inp,outp,result;  // Declare variable "a" of type PImage
PGraphics pg;
  
float [][] S;
float [][] S1;

ArrayList<Point> pointList;

float poissonDiscRadius = 5;
float pointRadius = 1;

int numPoints = 10000; 
float poissonDiscAccuracy = 0.005;

////////////////////////////////////////////////////////////

class Point {
  float x,y,z,r; 
  float tx,ty,n;
  
  Point(float px, float py) {
    x = px; y=py; z=0; r = 1; 
  }
  
  Point(float px, float py, float pz, float pr) {
    x = px; y=py; z=pz; r = pr; 
  }
  
  Point (Point p) {
    x = p.x; y= p.y; r = p.r;  
  }
  
  float dist(float px, float py) {
     return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }
  
  float dist(Point p) {
    return sqrt((x-p.x)*(x-p.x) + (y-p.y)*(y-p.y));
  }  
}

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

PImage createOutputImage(float [][] O) {
  
    int w = O.length;
    int h = O[0].length;

    outp = createImage(w, h ,RGB);
    for (int y=0; y<h; y++)
      for (int x = 0; x<w; x++) {
        float val = 255.0*O[x][y];
        outp.pixels[x+y*w] = color(val,val,val);
    }
    
    return outp;
}

///////////////////////////////////////////////////

void createIntensityVal(PImage a, float[][] S) {
  a.loadPixels();
  for (int y=0;y<a.height;y++)
    for (int x = 0; x < a.width; x++) 
       S[x][y] = brightness(a.pixels[x+y*a.width])/255.0;
}

///////////////////////////////////////////////////

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] S) {

  int w = S.length;
  int h = S[0].length;
  x1 = max(0,min(w,x1));
  x2 = max(0,min(w,x2));
  y1 = max(0,min(h,y1));
  y2 = max(0,min(h,y2));
  float r = 0;
  
  for (int y=y1; y<y2; y++)
    for (int x = x1; x<x2; x++) 
       r += S[x][y];
 
  return r/((x2-x1)*(y2-y1));
}

///////////////////////////////////////////////////////////
//
// stuff regarding points
//
///////////////////////////////////////////////////////////

boolean insertPoint(float [][] S,float x, float y) {
  
  boolean accepted = true;
  int px = (int)round(x);
  int py = (int)round(y);
  
  float it = getAvgIntensity(px-2,py-2,px+2,py+2,S);

  // program this, accept point only if the place is dark enough... 
     
  // if accepted:
  pointList.add(new Point(x,y,0,pointRadius));
  
  return accepted;
}

///////////////////////////////////////////////////////////

boolean insertPointPoissonDisc(float [][] S,float x, float y) {
  
  boolean accepted = false;
  int px = (int)round(x);
  int py = (int)round(y);
  
  // get Intensity of a small area around (px,py)
  float it = getAvgIntensity(px-2,py-2,px+2,py+2,S);

  // program this
  
  return accepted;
}

///////////////////////////////////////////////////

void createPoints() {
  
  pointList.clear();
  
  int points=0;
  int trials=0;
  do {
    float positionX = random(0,width-1);
    float positionY = random(0,height-1);
    boolean accepted = insertPoint(S,positionX,positionY);
    if (accepted) points++;
    trials++;
    if ((trials % 1000) == 0) 
      println(points + " " + trials + " " + (inp.width*inp.height)/(2.0*pointRadius*pointRadius));
  } while ((points<numPoints) && (trials<(inp.width*inp.height)/(2*pointRadius*pointRadius)));
}

///////////////////////////////////////////////////

void createPointsPoissonDisc() {
  
  pointList.clear();
  
  int points=0;
  int trials=1;
  while (((float)points/trials)<poissonDiscAccuracy) {
    float positionX = random(0,width-1);
    float positionY = random(0,height-1);
    boolean accepted = insertPointPoissonDisc(S,positionX,positionY);
    if (accepted) points++;
    trials++;
    if ((trials % 1000) == 0)
      println(points + " " + (float)points/trials + " " + poissonDiscAccuracy );
  } 
}

///////////////////////////////////////////////////

void movePoints() {

// program this

}

///////////////////////////////////////////////////
//
// render all points of point list into a new image
//
///////////////////////////////////////////////////

PImage createOutputImage() {
  
  PGraphics pg = createGraphics(width, height);

  pg.beginDraw();
  pg.background(255);
  pg.fill(0);
  for (int i=0;i<pointList.size();i++) {
    Point p = (Point)pointList.get(i);
    pg.ellipse(p.x,p.y,2*p.r,2*p.r);
  }
  pg.endDraw();

  return pg;
}

///////////////////////////////////////////////////////////
  
void setup() {

  inp = loadImage("data/stone_figure.png");
  inp.resize(0,1000); // proportional scale to height=1000

  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
//  frameRate(3);
 print(width*height);
  pointList = new ArrayList<Point>(1000);

  S = new float [inp.width][inp.height];
  S1 = new float [inp.width][inp.height];
  createIntensityVal(inp,S);
  createIntensityVal(createImage(width,height,RGB),S1);
  outp = inp;
  
    frameRate(30);
    background(255);
    fill(0);
    stroke(0);
  
  result = createImage(width,height,RGB);
}

////////////////////////////////////////////////////////////

void draw() {
  int pointRadius = 1;
  createIntensityVal(result,S1);
  
  for(int i=0; i<10000;i++) {
  int px= (int)random(5,width-6);
  int py= (int)random(5,height-6);
  float it = getAvgIntensity(px-5,py-5,px+5,py+5,S);
  float it1 = getAvgIntensity(px-5,py-5,px+5,py+5,S1);
   
   if(it1>it)
     ellipse(px,py,pointRadius,pointRadius);
  
  }
  
  result = copy();
}


////////////////////////////////////////////////////////////

void keyPressed() {
  if (key=='1') {
     outp = inp;
  }
  if (key=='2') {
      createPoints();
      outp = createOutputImage();
  }  
  if (key=='3') {
      createPointsPoissonDisc();
      outp = createOutputImage();
  }  
  if (key=='4') {
      movePoints();
      outp = createOutputImage();
  }  
  if (key=='s') {
      outp.save("data/output/outp.png");
  }  

}
