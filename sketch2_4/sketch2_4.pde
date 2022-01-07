PImage inp, outp;  // Declare variable "a" of type PImage //<>// //<>//
// Declare variable "a" of type PImage
PGraphics pg;

float [][] S;
ArrayList<Point> pointList;
ArrayList<Disc> discList;

float poissonDiscRadius = 5;
float pointRadius = 1;

int numPoints = 10000; 
float poissonDiscAccuracy = 0.005;

////////////////////////////////////////////////////////////

class Point {
  float x, y, z, r; 
  float tx, ty, n;

  Point(float px, float py) {
    x = px; 
    y = py; 
    z = 0; 
    r = 1;
  }

  Point(float px, float py, float pz, float pr) {
    x = px; 
    y = py; 
    z = pz; 
    r = pr;
  }

  Point (Point p) {
    x = p.x; 
    y = p.y; 
    r = p.r;
  }

  float dist(float px, float py) {
    return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }

  float dist(Point p) {
    return sqrt((x-p.x)*(x-p.x) + (y-p.y)*(y-p.y));
  }
}

class Disc {
  float x, y, r;

  Disc(float px, float py, float radius) {
    x = px; 
    y = py; 
    r = radius;
  }

  float dist(float px, float py) {
    return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }
}
///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

//PImage createOutputImage(float [][] O) {

//    int w = O.length;
//    int h = O[0].length;

//    outp = createImage(w, h ,RGB);
//    for (int y=0; y<h; y++)
//      for (int x = 0; x<w; x++) {
//        float val = 255.0*O[x][y];
//        outp.pixels[x+y*w] = color(val,val,val);
//    }

//    return outp;
//}

///////////////////////////////////////////////////

void createIntensityVal(PImage a, float[][] S) {
  a.loadPixels();
  for (int y=0; y<a.height; y++)
    for (int x = 0; x < a.width; x++) 
      S[x][y] = brightness(a.pixels[x+y*a.width])/255.0;
}

///////////////////////////////////////////////////

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] S) {

  int w = S.length;
  int h = S[0].length;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));
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

boolean insertPoint(float [][] S, float x, float y) {

  boolean accepted = true;
  int px = (int)round(x);
  int py = (int)round(y);

  float it = getAvgIntensity(px-2, py-2, px+2, py+2, S);

  // program this, accept point only if the place is dark enough... 
  if (it < 0.8) {
    // if accepted:
    pointList.add(new Point(x, y, 0, pointRadius));
  } else {
    accepted = false;
  }
  return accepted;
}

///////////////////////////////////////////////////////////

boolean insertPointPoissonDisc(float [][] S, float x, float y) {

  boolean accepted = true;
  int px = (int)round(x);
  int py = (int)round(y);

  // get Intensity of a small area around (px,py)
  float it = getAvgIntensity(px-2, py-2, px+2, py+2, S);
  if (it < 0.8 && isFarEnough(x, y, discList)) {
    // if accepted:
    pointList.add(new Point(x, y, 0, pointRadius));
    discList.add(new Disc(x, y, poissonDiscRadius));
  } else {
    accepted = false;
  }
  // program this
  return accepted;
}

boolean isFarEnough(float x, float y, ArrayList<Disc> plist) {
  Point p= new Point(x, y);

  for (Disc d : plist) {
    if (p.dist(d.x, d.y) < d.r)
      return false;
  }
  return true;
}

///////////////////////////////////////////////////

void createPoints() {

  pointList.clear();

  int points=0;
  int trials=0;
  do {
    float positionX = random(0, width-1);
    float positionY = random(0, height-1);
    boolean accepted = insertPoint(S, positionX, positionY);
    if (accepted) points++;
    trials++;
    if ((trials % 1000) == 0) 
      println(points + " " + trials + " " + (inp.width*inp.height)/(2.0*pointRadius*pointRadius));
  } while ((points<numPoints) && (trials<(inp.width*inp.height)/(2*pointRadius*pointRadius)));
}

///////////////////////////////////////////////////

void createPointsPoissonDisc() {

  pointList.clear();
  discList.clear();

  int points=0;
  int trials=1;
  do {
    float positionX = random(0, width-1);
    float positionY = random(0, height-1);
    boolean accepted = insertPointPoissonDisc(S, positionX, positionY);
    if (accepted) points++;
    trials++;
    //if ((trials % 1000) == 0)
    //println(points + " " + (float)points/trials + " " + poissonDiscAccuracy );
  } while ((points<numPoints) && (trials<(inp.width*inp.height)/(2*pointRadius*pointRadius)));
}

///////////////////////////////////////////////////

void movePoints() {

  // program this
  PImage vorImg = voronoiDiagram(inp, pointList); // image with the color coded cells
  if (vorImg == null) {
    return;
  }

  for (int i = 0; i < pointList.size(); i++) {
    Point tp = pointList.get(i);
    tp.tx = 0;
    tp.ty = 0;
    tp.n = 0;
  }
  
  for (int x = 0; x < width; x++ ) {
    println("column:"+ x);
    for (int y = 0; y < height; y++) {
      int ic = colorToInt(vorImg.get(x, y)); // index of the generating point
      pointList.get(ic).tx += x; // sum up pixel positions of that point
      pointList.get(ic).ty += y;
      pointList.get(ic).n += 1; // sum pixels that belong to that point
    }
  }

  for (int j = 0; j < pointList.size(); j++) {
    // compute center of gravity for each
    pointList.get(j).x = pointList.get(j).tx/pointList.get(j).n;
    pointList.get(j).y = pointList.get(j).ty/pointList.get(j).n;
    }
  }

PImage voronoiDiagram (PImage img, ArrayList<Point> pList) {
  if (pointList.size()==0) {
    print("point list empty");
    return null;
  }
  
  PImage vimg = createImage(img.width, img.height, RGB);
  for (int x = 0; x < width; x++ ) {
    println("column:"+ x);
    for (int y = 0; y < height; y++) {
      Point cp = new Point(x, y, 0, 1);
      float min_d = cp.dist(pList.get(0));
      for (int i = 0; i < pList.size(); i++) {
        float d = cp.dist(pList.get(i));
        if (d <= min_d) {
          vimg.set(x, y, intToColor(i));
          min_d = d;
        }
      }
    }
  }
  return vimg;
}

color intToColor(int i) {
  int r = i & 0xFF;
  int g = (i>>8) & 0xFF;
  int b = (i>>16) & 0xFF;
  return color(r, g, b);
}

int colorToInt(color c) {
  int r = (int)(c>> 16 & 0xFF);
  int g = (int)(c>> 8 & 0xFF);
  int b = (int)(c & 0xFF);
  return r + (g<<8) + (b<<16);
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
  for (int i=0; i<pointList.size(); i++) {
    Point p = (Point)pointList.get(i);
    pg.ellipse(p.x, p.y, 2*p.r, 2*p.r);
  }
  pg.endDraw();

  return pg;
}

///////////////////////////////////////////////////////////

void setup() {

  inp = loadImage("data/stone_figure.png");
  inp.resize(0, 1000); // proportional scale to height=1000

  size(10, 10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
  frameRate(3);

  pointList = new ArrayList<Point>(1000);
  discList = new ArrayList<Disc>(1000);

  S = new float [inp.width][inp.height];
  createIntensityVal(inp, S);
  outp = inp;
}

////////////////////////////////////////////////////////////

void draw() {
  image(outp, 0, 0);
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
