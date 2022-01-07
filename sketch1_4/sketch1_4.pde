// Sketch 1-1 threshold and random dither

// intensity source and target arrays
float [][] S,O,M;
PImage inp,outp,dither;  

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

// convert intensity array to RGB image
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

// convert RGB image to intensity array 
void createIntensityVal(PImage a, float[][] S) {
  a.loadPixels();
  for (int y=0;y<a.height;y++)
    for (int x = 0; x < a.width; x++) 
       S[x][y] = brightness(a.pixels[x+y*a.width])/255.0;
}

void digital_screening(float[][] S, float[][] M, float[][] O) {

  int w = S.length;
  int h = S[0].length;  
  for (int y=0; y<h; y++)
    for (int x = 0; x<w; x++) {
      O[x][y] = (S[x][y]>(1-M[x%M.length][y%M.length])) ? 1.0 : 0.0;
    }
}
 
///////////////////////////////////////////////////

void dither_random(float[][] S, float[][] O) {

  int w = S.length;
  int h = S[0].length;

  for (int y=0; y<h; y++)
    for (int x = 0; x<w; x++) {
       float r = random(0.2, 0.8);
       if (S[x][y]> r) {
           O[x][y] = 1;
       } else {
           O[x][y] = 0;
       }
    }
} 


///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 
  size(500,500); // size must always have fixed parameters...
    
  inp = loadImage("data/blume.png"); // load input image as RGB image
  inp.resize(500,500);  // resize to window size
  
  dither = loadImage("data/dither4.png");
  int sizeM = 16;
  dither.resize(sizeM,sizeM);
  // initialize intensity arrays
  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];
  M = new float [dither.width][dither.height];

  // create source intensity array from input RGB image
  createIntensityVal(dither,M);
  createIntensityVal(inp,S);
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
      digital_screening(S,M,O);
      outp = createOutputImage(O);
  }
    if (key=='3') {
      dither_random(S,O);
      outp = createOutputImage(O);
  }
  if (key == 's') save("output.png");
}
