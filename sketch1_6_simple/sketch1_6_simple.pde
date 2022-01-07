// Sketch 1-6 screening with characters 
 
float [][] S,O,M;

PImage inp,outp;  // Declare variable "a" of type PImage
int maskX = 8;
int maskY = 14;

PFont pf;
PImage chars[];


///////////////////////////////////////////////////

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

/////////////////////////////////////////////////

void createFontImages() {
  
  PGraphics g = createGraphics(maskX, maskY);
  char[] alphabet = "cdefghijklmnopqrstuvwxyz£#${[]}<>/\\ab".toCharArray();
  chars = new PImage[alphabet.length];
  pf = loadFont("AbadiMT-CondensedExtraBold-20.vlw");

  g.beginDraw();
  for (int i=0;i<alphabet.length;i++) {
          int charSize;
    charSize = round(3+i*0.8); //<>// //<>//
    g.textFont(pf, charSize-2); 
    g.background(255);
    g.stroke(0); 
    g.fill(0);
    g.textAlign(CENTER,CENTER);
    g.text(alphabet[i],maskX/2-1,maskY/2-2);
    chars[i]=g.get(0,0,maskX,maskY);
  }
  g.endDraw();
}

///////////////////////////////////////////////////  

void dither_screening_characters(float[][] S, float[][] O) {

  int w = S.length;
  int h = S[0].length;

  for (int y=0; y<h; y+=maskY)
    for (int x = 0; x<w; x+=maskX) {

      // get the blackness value (1-Intensity)
      float val = 1.0-getAvgIntensity(x,y,x+maskX,y+maskY,S);

      // get the right character Image
      int i = constrain((int)round(val*37),0,36);

      // copy the image to the right place
      for (int y1=0; y1<maskY; y1++) 
        for (int x1=0; x1<maskX; x1++) {
          if (((x+x1)<w) && ((y+y1)<h))
            O[x+x1][y+y1] = brightness(chars[i].pixels[x1+y1*maskX])/255.0;
        }
     }
}

///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 

  inp = loadImage("data/blume.png");
  inp.resize(0,1000); // proportional scale to height=500

  size(100,100); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height); // this is now the actual size
  frameRate(3);
  
  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];
  M = new float [maskX][maskY];

  createIntensityVal(inp,S);

  outp = inp;   
    
  createFontImages();
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
      dither_screening_characters(S,O);
      outp = createOutputImage(O);
  }
}
