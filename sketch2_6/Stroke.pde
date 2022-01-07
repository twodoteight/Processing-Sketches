class Stroke {
  ArrayList<PVector> plist;
  float wid;
  color col;

  Stroke() {
    col = color(255);
    wid = 3;
    plist = new ArrayList<PVector>();
  }
  
  Stroke(PVector pp, float pwid, color pcol) {
    col = pcol; 
    wid = pwid;
    plist = new ArrayList<PVector>();
    plist.add(pp);
  }
  
  void addPoint(PVector pp) {
    plist.add(pp);
  }
  
  void addPoint(float px, float py) {
    plist.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    wid = pr;
  }
  
  void setColor(color pcol) {
    col = pcol;
  }
  
  //-------------------------------------------------------------

  void draw() {

   stroke(col);
   strokeWeight(wid); 
   for(int i=1; i<plist.size(); i++) 
       line(plist.get(i-1).x,plist.get(i-1).y,
            plist.get(i).x,plist.get(i).y);
 }

 //---------------------------------------------- 
  
  void movePerpendicuarToGradient(int steps,PImage inp) { //<>//
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    color col = inp.get(actX,actY);
    
    for (int i=0; i<steps; i++) {
      tracePosition(inp);
      // TODO!
      
      // Program tracePosition first.
      // Stop if you notice the collor difference is getting too large.
      actX = (int)round(plist.get(plist.size()-1).x);
      actY = (int)round(plist.get(plist.size()-1).y);
      color actC = inp.get(actX,actY);
      
      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > 50) 
         break;
    }
  }
  
 //---------------------------------------------- 

  void tracePosition(PImage inp) { //<>//
    
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    int w = inp.width;
    
    //float dx=0, dy=0;
    
    // TODO
    // Compute the gradient and find the next position to go to
    // (use wid * someConstant)
    // update dx and dy accordingly, so it's added to plist in the next line.
    
    if (inp == null) return;
    actX = constrain(actX,1,inp.width-2);
    actY = constrain(actY,1,inp.height-2);
    
    // Gradient 
    float gx =   (brightness(inp.pixels[actX-1 + (actY-1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX-1 + (actY  )*w]) - brightness(inp.pixels[actX+1 + (actY  )*w])) +
                 (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w])) + 
               2*(brightness(inp.pixels[actX   + (actY-1)*w]) - brightness(inp.pixels[actX   + (actY+1)*w])) +
                 (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX+1 + (actY+1)*w]));
                 
    // Normalize 
    float len = sqrt(sq(gx)+sq(gy));    
    if (len==0) return;
    
    gx /= len;
    gy /= len;

   // Find the new postion
    float stepSize = 2;
    float dx = -gx*stepSize;
    float dy = gy*stepSize;
    
    plist.add(new PVector(actX+dy,actY+dx));
 }
}
