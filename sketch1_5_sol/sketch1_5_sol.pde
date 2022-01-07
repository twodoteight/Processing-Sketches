// Sketch 1-5 

float [][] S, O;
PImage inp, outp;  // Declare variable "a" of type PImage
float rotate = 0.f;
boolean sineDisplace = true;
float sineFreq = 1.f;
float sineScale =  0.25f;
float sinePhase = 0.f;
float I = 0.5f;

float k_w_scale = 1.f / 16.f;
float k_h_scale = 1.f / 16.f;

///////////////////////////////////////////////////

PImage createOutputImage(float [][] O) {

  int w = O.length;
  int h = O[0].length;

  outp = createImage(w, h, RGB);
  for (int y=0; y<h; y++)
    for (int x = 0; x<w; x++) {
      float val = 255.0*(O[x][y]);
      outp.pixels[x+y*w] = color(val, val, val);
    }

  return outp;
}

///////////////////////////////////////////////////

void createIntensityVal(PImage a, float[][] S) {
  for (int y=0; y<a.height; y++)
    for (int x = 0; x < a.width; x++) 
      S[x][y] = (brightness(a.pixels[x+y*a.width]))/255.0;
}

///////////////////////////////////////////////////

PImage createRamp(int w, int h)
{
  PImage ramp = createImage(w, h, RGB);
  for (int y=0; y<h; y++)
    for (int x = 0; x < w; x++) 
    {
      float b = ((w - y - 1) / ((float) h));
      ramp.set(x, y, color(b*255));
    }   
  return ramp;
}


///////////////////////////////////////////////////
//
// the different dither routines insert here
//
///////////////////////////////////////////////////

void mapModulo(int[] p, int mw, int mh, float[] mapped)
{
  mapped[0] = (p[0] % mw) / (float)mw;
  mapped[1] = (p[1] % mh) / (float)mh;
}

void rotate2D(int[] r, float radians)
{
  float x = (float)r[0];
  float y = (float)r[1];

  r[0] = (int)(x*cos(radians)-y*sin(radians));
  r[1] = (int)(x*sin(radians)+y*cos(radians));
}


void rotatePos(int[] p, int w, int h, float radians)
{
  p[0] -= w;
  p[1] -= h;
  rotate2D(p, radians);
  p[0] +=  w;
  p[1] +=  h;
}

//////////////////////////////////////////////////////////////

float kernel_cross(float s, float t, float I)
{
  return (s <= I) ? I*t : (1.f - I) * s + I;
}

//////////////////////////////////////////////////////////////

float kernel_double_sided_ramp(float s, float t, float I)
{
  return (s <= I) ? 2.f*s : 2.f-2.f*s;
}

//////////////////////////////////////////////////////////////

void displace_sine(float[] st, float scale, float freq, float phase)
{
  st[0] +=  scale*sin(st[1] * freq * TWO_PI + phase);
  st[1] +=  scale*sin(st[0] * freq * TWO_PI + phase);
  if (st[0]<0) st[0] += 1;
  if (st[0]>1) st[0] -= 1;
  if (st[1]<0) st[1] += 1;
  if (st[1]>1) st[1] -= 1;
}

//////////////////////////////////////////////////////////////

void dither_screen_proc(float[][] S, float[][] O) {

  int w = S.length;
  int h = S[0].length;
  int mw = (int) (w  * k_w_scale);
  int mh = (int) (h  * k_h_scale);
  float[] st = new float[2];
  float i;
  int[] pos = new int[2];

  for (int y=0; y<h; y++)   
    for (int x = 0; x<w; x++) 
    {
      pos[0] = x;
      pos[1] = y;

      // kernel mapping
      rotatePos(pos, w, h, rotate); 
      mapModulo(pos, mw, mh, st);

      // displace
      if (sineDisplace)
        displace_sine(st, sineScale, sineFreq, sinePhase);

      // apply dither kernel
      // i = kernel_double_sided_ramp(st[0], st[1], I);
      i = kernel_cross(st[0], st[1], 0.3f);

      O[x][y] = (S[x][y] <= i) ? 0f : 1f;
    }
}

///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 

  inp = createRamp(800, 800);

  size(800, 800);
  frameRate(3);

  S = new float [inp.width][inp.height];
  O = new float [inp.width][inp.height];

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
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='3') {
    sineDisplace = !sineDisplace;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='r') {
    rotate += 0.125f * HALF_PI;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='f') {
    sineFreq += 0.5f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='v') {
    sineFreq -= 0.5f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='s') {
    sineScale += 0.05f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='x') {
    sineScale -= 0.05f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='+') {
    I += 0.1f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='-') {
    I -= 0.1f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='l') {
    k_w_scale *= 0.5f;
    k_h_scale *= 0.5f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
  if (key=='o') {
    k_w_scale *= 2.f;
    k_h_scale *= 2.5f;
    createIntensityVal(inp, S);
    dither_screen_proc(S, O);
    outp = createOutputImage(O);
  }
}