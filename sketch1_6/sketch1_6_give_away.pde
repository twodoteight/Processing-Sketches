// Sketch 1-6 screening with characters 

PImage input;
PImage output;

PGraphics buffer;

int blockSize = 10;

///////////////////////////////////////////////////

float getAvgIntensity(int x1, int y1, int x2, int y2, PImage source) {
  source.loadPixels();
  
  int w = source.width;
  int h = source.height;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));
  float r = 0;

  for (int y=y1; y<y2; y++)
    for (int x = x1; x<x2; x++) 
      r += brightness(source.get(x, y)); // (0-255) brightness

  return r/((x2-x1)*(y2-y1));
}


/////////////////////////////////////////////////

// create an image of size rSize containing the letter c with size textSize
PImage createLetter(char c, int rSize, int textSize) {
  PGraphics out = createGraphics(rSize, rSize);
  
  PFont font = createFont("Georgia", textSize);
  
  out.beginDraw();
  out.stroke(0);
  out.fill(0);
  out.background(255);
  out.textFont(font);
  out.textAlign(CENTER, TOP);
  out.translate(rSize/2, rSize/2);
  out.text(c, 0, -(out.textAscent()+out.textDescent())/2);
  out.endDraw();
  
  return out;
}

///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 
  input = loadImage("data/blume.png");
  input.resize(0,1000); // proportional scale to height=1000

  size(100,100); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(input.width, input.height); // this is now the actual size
  frameRate(3);
  
  buffer = createGraphics(input.width, input.height);

  buffer.beginDraw();
  buffer.background(255);
  buffer.endDraw();
  
  output = input;
  
  frameRate(2);
  
  // TODO create a list/map of letters of size 256 using the createLetter function and blockSize
  // the letter size has to be set according to the 256 grey levels (use the getAverageIntensity function)
}

/////////////////////////////////////////////////////
//
// this is automatically executed frameRate()-times
// per second
//
/////////////////////////////////////////////////////

void draw() {
  image(output, 0, 0);
}

//////////////////////////////////////////////////////////////

// run the screening with text algorithm
void screeningWithText(PImage source, PGraphics buffer) {
  
  // just an example showing the usage of createLetter
  buffer.beginDraw();
  PImage l = createLetter('A', buffer.width, 120);
  buffer.image(l, 0, 0, buffer.width, buffer.height);
  buffer.endDraw();
  
  // TODO implement screening by block wise iterating over the image (blockSize)
  // 1 estimate average intensity of the current block in source
  // 2 choose the corresponding letter in your letter list
  // 3 render the letter to the buffer
  // ...
}

//////////////////////////////////////////////////////////////

void keyPressed() {
  if (key=='1') {
    output = input;
  }
  if (key=='2') {
    screeningWithText(input, buffer);
    output = buffer;
  }
}
