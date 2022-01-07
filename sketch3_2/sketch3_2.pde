// Sketch 3-1 

float [][] S, O;
int iheight=500;

PImage inp, outp, depth, nmap;  // Declare variable "a" of type PImage

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

///////////////////////////////////////////////////

PImage selectChannel(PImage img, int no) {

  PImage res = createImage(img.width, img.height, RGB);
  img.loadPixels();

  for (int y=0; y<img.height; y++) 
    for (int x=0; x<img.width; x++) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      if(r != 255 || g != 255 || b != 255) {
      }
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

PImage modulateImage1(PImage img, PImage depth, PImage nmap) {

PImage res = createImage(depth.width, depth.height, RGB);
  
  PImage edges = createEdgesCanny(img, 2, 6);
  PImage red = createEdgesCanny(selectChannel(depth,0), 2, 6);
  
  PImage nEdges = createEdgesCanny(selectChannel(nmap,0), 2, 6);
  PImage nGreenEdges = createEdgesCanny(selectChannel(nmap,1), 2, 6);
  PImage nBlueEdges = createEdgesCanny(selectChannel(nmap,2), 2, 6);
  nEdges.blend(nGreenEdges,0,0,res.width,res.height,0,0,res.width,res.height, DARKEST);
  nEdges.blend(nBlueEdges,0,0,res.width,res.height,0,0,res.width,res.height, DARKEST);
  
  for (int i=0; i<res.width*res.height; i++) {
    res.pixels[i] = white;
    
      if (red.pixels[i] == black) {
        res.pixels[i] = color(255,0,0);
      }
      if (nEdges.pixels[i] == black) {
        res.pixels[i] = color(0,0,255);
      }
        if(edges.pixels[i] == black) {
         res.pixels[i] = black;
      }

  }
    res.updatePixels();

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

///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 

  //inp = loadImg("Select Input image");
  inp = loadImage("data/venus.png");
  inp.resize(0, iheight); // proportional scale to height=500

  size(500, 500); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height); // this is now the actual size
  frameRate(3);

  // depth = loadImg("Select depth Image");
  depth = loadImage("data/venus_depth.png");
  depth.resize(0, iheight); // proportional scale to height=500

  //nmap = loadImg("Select normal Image");
  nmap = loadImage("data/venus_normal.png");
  nmap.resize(0, iheight); // proportional scale to height=500

  outp = inp;
}

/////////////////////////////////////////////////////
//
// this is automatically executed frameRate()-times
// per second
//
/////////////////////////////////////////////////////

void draw() {

  // Displays the image at its actual size at point (0,0)
  image(outp, 0, 0);
}

//////////////////////////////////////////////////////////////

void keyPressed() {
  if (key=='1') {
    outp = inp;
  }
  if (key=='2') {
    outp = depth;
  }
  if (key=='3') {
    outp = nmap;
  }

  if (key=='4') { 
    outp = createEdgesCanny(inp, 4, 14);
  }

  if (key=='5') { 
    outp = createEdgesCanny(depth, 4, 14);
  }

  if (key=='6') {
    outp = modulateImage1(inp, depth, nmap);
  }
    if (key=='m') {
    outp = method(inp, depth);
  }
    if (key=='ı') {
    outp = selectChannel(depth, 0);
  }
     if (key=='o') {
    outp = selectChannel(depth, 1);
  }
     if (key=='p') {
    outp = selectChannel(depth, 2);
  }
}
