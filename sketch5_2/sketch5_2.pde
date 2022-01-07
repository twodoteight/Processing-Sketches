import java.util.Collections;


float [][] S, O;
int iheight=600;
float clow=1.4;
float chigh=1.4;
int outputMode = 1;
int inputMode = 2;
boolean inputChanged = false;
PImage inp, outp, depth, nv, nmap, ngrad, contourImg, tmp;  // Declare variable "a" of type PImage
PVector gw, gpv;

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

PImage selectChannel(PImage img, int no) {

  PImage res = createImage(img.width, img.height, RGB);
  img.loadPixels();

  for (int y=0; y<img.height; y++) 
    for (int x=0; x<img.width; x++) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      switch (no) {
      case 0: 
        res.pixels[x+y*img.width] = color(r, r, r);
        break;
      case 1: 
        res.pixels[x+y*img.width] = color(g, g, g);
        break;
      case 2: 
        res.pixels[x+y*img.width] = color(b, b, b);
        break;
      }
    }
  res.updatePixels();

  return res;
}

///////////////////////////////////////////////////

PImage markDepth(PImage depth, int ddepth) {

  PImage res = createImage(depth.width, depth.height, RGB);
  depth.loadPixels();

  for (int y=0; y<depth.height; y++) {
    for (int x=0; x<depth.width; x++) {
      float d = brightness(depth.pixels[x+y*depth.width]);
      res.pixels[x+y*depth.width] = 
        (d==ddepth) ? color(255, 0, 0) : color(0, 0, 0);
    }
  }
  res.updatePixels();

  return res;
}

PVector rgbToNormal(color c) {
  PVector v = new PVector(red(c)-127, 127f-green(c), blue(c)-127);
  v.normalize();
  return v;
}

/////////////////////////////////////////////////////////////////////////////

color gradientToRGB(float dx, float dy) {

  float fac = 1;

  float gx = max(-10, min(10, dx*fac));
  float gy = max(-10, min(10, dy*fac));
  float r = (gx+10)*12f;
  float g = (gy+10)*12f;
  float b = 127f;

  return color(r, g, b);
}

PVector RGBToGradient(color c) {

  return new PVector((red(c)-10)/12f, (green(c)-10)/12f);
}

/////////////////////////////////////////////////////////////////////////////

PImage computeNV(PImage img) {
  PImage res = createImage(img.width, img.height, RGB);

  PVector v = new PVector(0, 0, 1);

  for (int i=0; i<img.width*img.height; i++) {
    // TODO
    PVector n = rgbToNormal(img.pixels[i]);
    float nv = n.dot(v);
    res.pixels[i] = color(nv*255);
  }

  return res;
}

/////////////////////////////////////////////////////////

PImage computeGradient(PImage img) {

  PImage res = createImage(img.width, img.height, RGB);

  for (int i=0; i<img.width*img.height; i++)
    res.pixels[i] = color(128, 128, 128);

  for (int y=1; y<img.height-1; y++) {
    for (int x=1; x<img.width-1; x++) {
      // TODO
      // load the brigntnesses from each pixel required by the sobel opperator (replace the 0.0s)
      float g11 = brightness(img.pixels[(x-1)+(y-1)*img.width]);
      float g12 = brightness(img.pixels[(x)+(y-1)*img.width]);
      float g13 = brightness(img.pixels[(x+1)+(y-1)*img.width]);
      float g21 = brightness(img.pixels[(x-1)+(y)*img.width]);
      float g22 = brightness(img.pixels[(x)+(y)*img.width]);
      float g23 = brightness(img.pixels[(x+1)+(y)*img.width]);
      float g31 = brightness(img.pixels[(x-1)+(y+1)*img.width]);
      float g32 = brightness(img.pixels[(x)+(y+1)*img.width]);
      float g33 = brightness(img.pixels[(x+1)+(y+1)*img.width]);
      // pass the correct dx, dy components to get a color.
      float dx = (g13-g11)+2*(g23-g21)+(g33-g31);
      float dy =  (g33-g13)+2*(g32-g12)+(g31-g11);
      res.pixels[x+y*img.width] = gradientToRGB(dx, dy);
    }
  }

  return res;
}   

/////////////////////////////////////////////////////////////////////////////

PImage createEdgesCanny(PImage img, float low, float high) {

  //create the detector CannyEdgeDetector 
  CannyEdgeDetector detector = new CannyEdgeDetector(); 

  //adjust its parameters as desired 
  detector.setLowThreshold(low); 
  detector.setHighThreshold(high); 

  //apply it to an image 
  detector.setSourceImage(img);
  detector.process(); 
  return detector.getEdgesImage();
}


boolean isMinimum(int px, int py, PImage img) {
  int rad = 5;
  float epsilon=0;

  int xmin = max(0, px-rad);
  int ymin = max(0, py-rad);
  int xmax = min(img.width, px+rad);
  int ymax = min(img.height, py+rad);
  float vmin=red(img.pixels[px+py*img.width]); 

  for (int y=ymin; y<ymax; y++) 
    for (int x=xmin; x<xmax; x++) {
      float v=red(img.pixels[x+y*img.width]); 
      if (v<vmin) return false;
    }

  return true;
}



///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////
public void settings() {
  size(10, 10);
}
void setup() { 
  reset();
}

/////////////////////////////////////////////////////
//
// this is automatically executed frameRate()-times
// per second
//
/////////////////////////////////////////////////////

void draw() {
}

////////////////////////////////////////////////////////////////

void renderModal() {
  switch(outputMode) {
  case 1: 
    outp = inp;
    break;
  case 2: 
    outp = depth;
    break;
  case 3: 
    outp = nmap;
    break;
  case 4: 
    outp = ngrad; // or ngrad
    break;
  case 5: 
    outp = createEdgesCanny(depth, clow, chigh);
    break;
  case 6: 
    outp = createEdgesCanny(ngrad, clow, chigh);
    break;
  }
}

void reset(){
    switch (inputMode) {
  case 1: 
    inp = loadImage(sketchPath("data/sphere.png"));
    depth = loadImage(sketchPath("data/sphere_depth.png"));
    nmap = loadImage(sketchPath("data/sphere_normals.png"));
    break;
  case 2:
    inp = loadImage(sketchPath("data/dragon.png"));
    depth = loadImage(sketchPath("data/dragon_depth.png"));
    nmap = loadImage(sketchPath("data/dragon_normals.png")); 
    break;
  case 3:
    inp = loadImage(sketchPath("data/venus.png"));
    depth = loadImage(sketchPath("data/venus_depth.png"));
    nmap = loadImage(sketchPath("data/venus_normals.png")); 
    break;
  }

  inp.resize(0, iheight); // proportional scale to height=500
  depth.resize(0, iheight); // proportional scale to height=500
  nmap.resize(0, iheight); // proportional scale to height=500

  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
  frameRate(3);

  outp = createImage(inp.width, inp.height, RGB);
  for (int i=0; i<outp.width*outp.height; i++) outp.pixels[i] = color(255, 255, 255);

  //contourImg = computeConourLines(nmap);
  //outp = contourImg;

  nv = computeNV(nmap);
  nv.filter(BLUR, 1);

  nmap.filter(BLUR, 1);

  ngrad = computeGradient(nv);
  ngrad.filter(BLUR, 1);

  outputMode = 1;
  renderModal();
}

//////////////////////////////////////////////////////////////

void keyPressed() {

  if (key=='b'||key=='n'||key=='m') {
    inputChanged = true;
    if (key=='b') inputMode = 1;
    if (key=='n') inputMode = 2;
    if (key=='m') inputMode = 3;
  }
  if (key=='1') outputMode = 1;
  if (key=='2') outputMode = 2;
  if (key=='3') outputMode = 3;
  if (key=='4') outputMode = 4;
  if (key=='5') outputMode = 5;
  if (key=='6') outputMode = 6;
  if (key=='y') if (clow>=0.2) clow -= 0.2;
  if (key=='x') if (clow<chigh) clow += 0.2;
  if (key=='q') if (chigh>clow) chigh -= 0.2;
  if (key=='w') chigh += 0.2;
  if (key=='s') { 
    save("result.png"); 
    exit();
  }
  println("Low: " + clow + " High: " + chigh);

if(inputChanged ==true) {
inputChanged = false;
reset();
}
  renderModal();  
  image(outp, 0, 0);
}

////////////////////////////////////////////////////////////

void mouseMoved() {

  PVector n = rgbToNormal(nmap.pixels[(int)mouseX+((int)mouseY)*nmap.width]);
  PVector v = new PVector(0, 0, 1);
  gw = n; // v.cross(n);

  stroke(255, 0, 0);
  image(outp, 0, 0);     
  line(mouseX, mouseY, mouseX+gw.x*50, mouseY+gw.y*50);
}
