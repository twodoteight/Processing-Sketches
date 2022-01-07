
// create source intensity array from input RGB image
void error_diffusion_2D(float[][] S, float[][] O) {
  float [][] T = new float [inp.width][inp.height];
  createIntensityVal(inp, T);

  int w = T.length;
  int h = T[0].length;
  float error;
  for (int y = 1; y<h-1; y++)
    for (int x = 1; x<w-1; x++) {
      float oldPixel = T[x][y];
      float newPixel;
      
      if (oldPixel> 0.5) {
        newPixel = 1;
      } else {
        newPixel = 0;
      }

      O[x][y] = newPixel;
      error = oldPixel- newPixel;

      T[x+1][y] = T[x+1][y] + error * 7/16; //<>//
      T[x-1][y+1] = T[x-1][y+1] + error * 3/16;
      T[x][y+1] = T[x][y+1] + error * 5/16;
      T[x+1][y+1] = T[x+1][y+1] + error * 1/16;
    }
}

void error_diffusion_1D(float[][] S, float[][] O) {
  // create source intensity array from input RGB image
  float [][] T = new float [inp.width][inp.height];
  createIntensityVal(inp, T);
  int w = S.length;
  int h = T[0].length;
  float pixVal;
  for (int y = 1; y<h-1; y++)
    for (int x = 1; x<w-1; x++) {
      if (T[x][y]> 0.5) {
        pixVal = 1;
      } else {
        pixVal = 0;
      }
      O[x][y] = pixVal;
      float error = T[x][y] - pixVal;
      if (x+1<T.length) {
        T[x+1][y] = T[x+1][y] + 7.0/16 * error;
      }
    }
}
// Sketch 1-1 threshold and random dither

// intensity source and target arrays
float [][] S, O;
PImage inp, outp;  

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

// convert intensity array to RGB image
PImage createOutputImage(float [][] O) {

  int w = O.length;
  int h = O[0].length;

  outp = createImage(w, h, RGB);
  for (int y=0; y<h; y++)
    for (int x = 0; x<w; x++) {
      float val = 255.0*O[x][y];
      outp.pixels[x+y*w] = color(val, val, val);
    }

  return outp;
}

///////////////////////////////////////////////////

// convert RGB image to intensity array 
void createIntensityVal(PImage a, float[][] S) {
  a.loadPixels();
  for (int y=0; y<a.height; y++)
    for (int x = 0; x < a.width; x++) 
      S[x][y] = brightness(a.pixels[x+y*a.width])/255.0;
}

///////////////////////////////////////////////////
//
// the different dither routines insert here
//
///////////////////////////////////////////////////

void dither_treshold(float[][] S, float[][] O) {

  int w = S.length;
  int h = S[0].length;

  for (int y=0; y<h; y++)
    for (int x = 0; x<w; x++) {
      if (S[x][y]> 0.5) {
        O[x][y] = 1;
      } else {
        O[x][y] = 0;
      }
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
  size(500, 500); // size must always have fixed parameters...

  inp = loadImage("data/blume.png"); // load input image as RGB image
  inp.resize(500, 500);  // resize to window size

  // initialize intensity arrays
  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];

  // create source intensity array from input RGB image
  createIntensityVal(inp, S);
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
    dither_treshold(S, O);
    outp = createOutputImage(O);
  }
  if (key=='3') {
    dither_random(S, O);
    outp = createOutputImage(O);
  }
  if (key=='4') {
    error_diffusion_1D(S, O);
    outp = createOutputImage(O);
  }
  if (key=='5') {
    error_diffusion_2D(S, O);
    outp = createOutputImage(O);
  }
  if (key == 's') save("output.png");
}
