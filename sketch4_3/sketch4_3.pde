// Sketch 3-1 
 
float [][] S,O;
int iheight=500;

PImage inp,outp,depth,nmap,bg;  // Declare variable "a" of type PImage

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

///////////////////////////////////////////////////

PImage selectChannel(PImage img, int no) {

  PImage res = createImage(img.width,img.height,RGB);
  img.loadPixels();
  
  for (int y=0;y<img.height;y++) 
    for (int x=0;x<img.width;x++) {
        float r = red(img.pixels[x+y*img.width]);
        float g = green(img.pixels[x+y*img.width]);
        float b = blue(img.pixels[x+y*img.width]);
        switch (no) {
          case 0: res.pixels[x+y*img.width] = color(r,r,r);
                  break;
          case 1: res.pixels[x+y*img.width] = color(g,g,g);
                  break;
          case 2: res.pixels[x+y*img.width] = color(b,b,b);
                  break;
        }
  }
  res.updatePixels();
  
  return res;
}

///////////////////////////////////////////////////

PImage toonify(PImage img, PImage depth, PImage nmap) {

  PImage nEdges = getEdges(img, nmap);
  PImage qim = quantization(img);
  
for(int i=0; i<nEdges.width*nEdges.height; i++) {
  if(brightness(nEdges.pixels[i]) != 255) {
  qim.pixels[i] = black;
  } 
}
  addBG(qim, bg);

  return qim; 
}

PImage quantization(PImage img) {
PImage res = createImage(img.width,img.height,RGB);  

for(int i=0; i<res.width*res.height; i++) {
  
  float pb = brightness(img.pixels[i]);
  
  if(pb == 255) {
  res.pixels[i] = color(255, 0);
  }
  else if(pb > 210) {
  res.pixels[i] = color(255, 255);
  } 
  else if(pb > 150 && pb <= 210) {
  res.pixels[i] = color(200,100);
  }
  else {
  res.pixels[i] = color(0,100);
  } 
}
 return res; 
}
void addBG(PImage img, PImage bg){

 for(int i=0; i<img.width*img.height; i++) {
   float imga = alpha(img.pixels[i]);
   if(imga != 255){
   color imgc = color(img.pixels[i]);
   color bgc = color(bg.pixels[i]);
    
    float newr = (red(imgc)*imga+red(bgc)*(255-imga))/255;
    float newg = (green(imgc)*imga+green(bgc)*(255-imga))/255;
    float newb = (blue(imgc)*imga+blue(bgc)*(255-imga))/255;
img.pixels[i] = color(newr,newg,newb);
 } 
 } 
}
PImage getEdges(PImage img, PImage nmap) {

  PImage nEdges = createEdgesCanny(selectChannel(nmap,0), 4, 15);
  PImage nGreenEdges = createEdgesCanny(selectChannel(nmap,1), 4, 15);
  PImage nBlueEdges = createEdgesCanny(selectChannel(nmap,2), 4, 15);
  
  
  nEdges.blend(nGreenEdges,0,0,img.width,img.height,0,0,img.width,img.height, DARKEST);
  nEdges.blend(nBlueEdges,0,0,img.width,img.height,0,0,img.width,img.height, DARKEST);
  
  return nEdges;
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
  bg = loadImage("data/bg.png");
  bg.resize(0,iheight);
  inp = loadImage("data/dragon.png");
  inp.resize(0,iheight); // proportional scale to height=500

  size(500,500); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height); // this is now the actual size
  frameRate(3);

  // depth = loadImg("Select depth Image");
  depth = loadImage("data/dragon_depth.png");
  depth.resize(0,iheight); // proportional scale to height=500

  //nmap = loadImg("Select normal Image");
  nmap = loadImage("data/dragon_normal.png");
  nmap.resize(0,iheight); // proportional scale to height=500

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
    outp = createEdgesCanny(inp,4,14);
  }
 
  if (key=='5') { 
    outp = createEdgesCanny(depth,4,14);
  }
 
  if (key=='6') {
     outp = toonify(inp,depth,nmap);
  }
  
  if (key=='o') {
     outp = quantization(inp);
  }
 
}
