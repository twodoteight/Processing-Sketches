// Sketch 1-1 threshold and random dither //<>// //<>//

// intensity source and target arrays
float [][] S, O, M;
PImage inp, outp, dither;  

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
PVector mapping(int kernelsize, int x, int y, int angle) {
  float s;
  float t;
  PVector xy= new PVector(x,y);
  
  xy.rotate(radians(angle));
  xy.x += width;
  xy.y += height;
  
  s = ((xy.x%kernelsize)/(float)kernelsize);
  t = ((xy.y%kernelsize)/(float)kernelsize);
 
  PVector a = new PVector(s, t);
 // float[] a = {s, t};
 
 // a.rotate(PI/3);
  return a;
}

void procedural(float[][] S, float[][] O, float k, int angle) {

  int w = S.length;
  int h = S[0].length;
  int kernelsize = 8;
 
  float s;
  float t;
  
  for (int x=0; x<w-1; x++)
    for (int y=0; y<h-1; y++) {
      PVector m = mapping(kernelsize, x, y, angle);
      s = m.x;
      t = m.y;
      
      float i = dither_kernel((float)s, (float)t, k);
     
      O[x][y] = (S[x][y]<i) ? 0.0 : 1.0;
    }
} //<>// //<>//

//float[][] output_kernel() {

//  int w = S.length;
//  int h = S[0].length;
//  int size = 16;
//  float[][] kernel = new float[size][size];
//  int[] m = new int[2];
//  int s;
//  int t;
//  float i;

//  for (int x=0; x<w; x++)
//    for (int y=0; y<h; y++) {
//      m = mapping(size, x, y);
//      s = floor(m[0]);
//      t = floor(m[1]);
//      i = dither_kernel(s, t, 0.5);
//      kernel[s][t]=i;
//    }
//  return kernel;
//}

float dither_kernel(float s, float t, float i) {
  if (s<i) { //<>//
    return i*t;
  } else {
    return ((1-i)*s)+i;
  }
}
float dither_kernel_sin(float s, float t, float i) {
  if (s<i) {
    return i*t;
  } else {
    return (((1-i)*s)+i);
  }
}
/* procedural(float[][] S, float[][] O){
 int w = S.length;
 int h = S[0].length;
 int s,t;
 (s,t)=dither_kernel(float[][] S,float[][] O, int s,int t, float I);
 mapping(float[][] S, float[][] M,float[][] O, int s,int t)
 for (int x = 0; x<w-1; x++){
 for (int y=0; y<h-1; y++){
 (s,t):= M(x,y)
 i := (s,t)
 
 if (S[x][y]> i) {
 O[x][y] = 1;
 } else {
 O[x][y] = 0;
 }
 
 }
 }
 
 
 
 
 } */
///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 
  size(500, 500); // size must always have fixed parameters...

  inp = loadImage("data/rampe2.png"); // load input image as RGB image
  inp.resize(500, 500);  // resize to window size

  dither = loadImage("data/dither4.png");
  int sizeM = 16;
  dither.resize(sizeM, sizeM);
  // initialize intensity arrays
  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];
  M = new float [dither.width][dither.height];

  // create source intensity array from input RGB image
  createIntensityVal(dither, M);
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
    procedural(S, O, 0.0, 20);
    outp = createOutputImage(O);
  }
    if (key=='3') {
    procedural(S, O, 0.0, 50);
    outp = createOutputImage(O);
  }
    if (key=='4') {
    procedural(S, O, 0.7, 20);
    outp = createOutputImage(O);
  }
    if (key=='5') {
    procedural(S, O, 0.3, 20);
    outp = createOutputImage(O);
  }

  if (key == 's') save("output.png");
}
