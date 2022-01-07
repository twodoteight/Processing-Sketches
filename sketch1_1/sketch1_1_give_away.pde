// Sketch 1-1 threshold and random dither

// intensity source and target arrays
float [][] S,O;
PImage inp,outp;  

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
  size(500,500); // size must always have fixed parameters...
    
  inp = loadImage("data/blume.png"); // load input image as RGB image
  inp.resize(500,500);  // resize to window size
  
  // initialize intensity arrays
  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];

  // create source intensity array from input RGB image
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
      dither_treshold(S,O);
      outp = createOutputImage(O);
  }
    if (key=='3') {
      dither_random(S,O);
      outp = createOutputImage(O);
  }
        if (key=='4') {
      error_diffusion_1D(S,O);
      outp = createOutputImage(O);
  }
          if (key=='5') {
      error_diffusion_2D(S,O);
      outp = createOutputImage(O);
  }
  if (key == 's') save("output.png");
}
