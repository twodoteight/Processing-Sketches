float [][] S, O; //<>// //<>//
PImage inp, outp;  

// create source intensity array from input RGB image
void line_error_diffusion(float[][] S, float[][] O, float tresh,int lm) {

  float [][] T = new float [inp.width][inp.height];
  createIntensityVal(inp, T);

  int w = T.length;
  int h = T[0].length;
  float K;
  float lineLenght = 8;
  float error;

  for (int y = h-1; y > 1 ; y--)
    for (int x = 1 ; x < w-1 ; x++) {
      if (T[x][y] < tresh) {
        K = 0;
        drawLine (O, x, y, lm);
        error = T[x][y] - K + (lm - 1);
      } else {
        K = 1;
        O[x][y] = K;
        error = T[x][y] - K;
      }
         
      T[x][y] = K;
      T[x+1][y] = T[x+1][y] + 7.0/16 * error;  
      T[x-1][y-1] = T[x-1][y-1] + 3.0/16 * error;
      T[x][y-1] = T[x][y-1] + 5.0/16 * error;
      T[x+1][y-1] = T[x+1][y-1] + 1.0/16 * error;
      }
}

void drawLine(float[][]O, int x, int y, float length)
{
  for(int i = 0; i < length; i++){
    if((x-i) > 0 && (y-i) > 0){ //<>//
       O[x-i][y-i] = 0;
    }    
  }
}
//////////////////////////////////////////////

// convert intensity array to RGB image
PImage createOutputImage(float [][] O) {

  int w = O.length;
  int h = O.length;

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
    line_error_diffusion(S, O, 0.5, 5);
    outp = createOutputImage(O);
  }
    if (key=='2') {
    line_error_diffusion(S, O, 0.1, 10);
    outp = createOutputImage(O);
  }
    if (key=='3') {
    line_error_diffusion(S, O, 0.9, 10);
    outp = createOutputImage(O);
  }

  if (key == 's') save("output.png");
}
