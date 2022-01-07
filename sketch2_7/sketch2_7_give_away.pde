PImage inp, texture;
ArrayList<Stroke> strokes;
int mode = 0;
float lineWidth=25;
float drawAlpha=30;
boolean resized = false;

////////////////////////////////////////////////////////

void createACoupleOfStrokes(int noStrokes) {

  for (int i=0; i<noStrokes; i++) {

    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    Stroke s = new Stroke(new PVector(px, py), lineWidth, col,texture);
    s.movePerpendicuarToGradient(20, inp); 

    strokes.add(s);
    println(strokes.size());
   
    s.draw();
  }
}

/////////////////////////////////////////////////////////
// draw the stroke at the position of the mouse
// for debugging, color is inverse to image
/////////////////////////////////////////////////////////

void createStrokeAtMousePosition() { 
  background(inp);
  int px = (int)mouseX;
  int py = (int)mouseY;
  color col = inp.pixels[px + py*inp.width];
  Stroke s = new Stroke(new PVector(px, py), lineWidth, 
                   color(255-red(col), 255-green(col), 255-blue(col)),texture);
  s.movePerpendicuarToGradient(20, inp); 
  s.draw();
}

/////////////////////////////////////////////////////////

void setup() {
  // Go to File > Preferences and increase
  println("sada");
  size(1000,1000,P3D);
  inp = loadImage("rampe.png");
  inp.resize(1000,0);
  surface.setResizable(true);
  
  surface.setSize(inp.width, inp.height);

  texture = loadImage("data/brush.png");

  strokes = new ArrayList<Stroke>(100);
  
  background(255);
  // Do not fill geometry. SInce we are using alphatransparency, this hsould be turned off.
  //noFill();
  // Do not paint outline for strokes. Enable this for debugging purposes!
  noStroke();
  textureMode(IMAGE);  
}

////////////////////////////////////////////////////////

void draw() {
  if (mode == 0) {
    createACoupleOfStrokes(100);
    // Don't keep all strokes in memory, otherwise we run out of heapspace
    strokes = new ArrayList<Stroke>(100);
  }
  if (mode == 1) createStrokeAtMousePosition();
}

////////////////////////////////////////////////////////

void keyPressed() {
  if (key == '0') mode = 0; 
  if (key == '1') mode = 1; 
  if (key == '-') lineWidth /= 1.5;
  if (key == '+') lineWidth *= 1.5;
}
