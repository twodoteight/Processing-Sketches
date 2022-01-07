class Stroke {
  ArrayList<PVector> plist;
  float wid;
  color col;
  PImage texi, _texi;
  float fx[][] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
 
  float fy[][] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

  Stroke() {
    col = color(0, 0, 0, 255);
    plist = new ArrayList<PVector>(10);
    wid = 10;
    iniTexture();
  }

  Stroke(PVector pp, float pw, color pc, PImage ptexi) {
    col = pc;
    wid = pw;
    texi = ptexi;
    plist = new ArrayList<PVector>(10);
    plist.add(pp);
    iniTexture();
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

    if (plist.size()<2) return;

    float len = getStrokeLength();
    float l=0, x=0, y=0;

    beginShape(QUAD_STRIP);
    texture(_texi); 
    normal(0, 0, 1); // only for lights
    for (int i = 0; i<plist.size(); i++) {
      PVector p = plist.get(i);
      if (i==0) {
        // initialize for first point
        x = p.x;  //<>//
        y = p.y; 
        l = 0;
      } else {
        // update length along the stroke
        l += sqrt(sq(x-p.x)+sq(y-p.y)); 
        x = p.x;  //<>//
        y = p.y;
      }      
      
      PVector n = getOffsetNormal(plist, i);
      float v = _texi.height * l/len;

      // TODO: create two vertices, one above and one below this point.
      // vertex: X, Y, 0, U , V
      // (the zero is Z)
      float xoff = wid/2 * n.x;
      float yoff = wid/2 * n.y;
      vertex(x+xoff, y+yoff, 0, _texi.width, v);
      vertex(x-xoff, y-yoff, 0, 0, v);
    }
    endShape();
  }

  //-------------------------------------------------------------

  float getStrokeLength() {
    float len = 0;
    for (int i = 1; i<plist.size(); i++) {
      PVector p  = plist.get(i);
      PVector pp = plist.get(i-1);
      len += sqrt(sq(pp.x-p.x)+sq(pp.y-p.y));
    }
    return len;
  }

  //-------------------------------------------------------------

  PVector getOffsetNormal(ArrayList<PVector> plist, int index) {

    PVector z = new PVector(0f, 0f, 1f);

    // implement these cases:
    // Index out of bounds? -> (0, 1)    
    // List of only one point?  -> (0, 1)
    if (plist.size() == 1 || index > plist.size()-1) {
      z = new PVector(0f, 1f, 0f);
    }
    // First point?
    if (index==0) {
      PVector pn = plist.get(index);
      PVector p1 = plist.get(index+1);
      z = PVector.sub(p1,pn).rotate(HALF_PI);
    }   
    // Last point?
    if (index==plist.size()-1) {
      PVector pn = plist.get(index);
      PVector p1 = plist.get(index-1);
      z = PVector.sub(pn,p1).rotate(HALF_PI);
      
    }   
    // Point in the middle with neighbors.
    if (index > 0 && index<plist.size()-1) {
      PVector pn = plist.get(index);
      PVector p1 = plist.get(index-1);
      PVector p2 = plist.get(index+1);
      z = PVector.add(PVector.sub(pn,p1).rotate(HALF_PI).normalize(), PVector.sub(p2,pn).rotate(HALF_PI).normalize());
    }

    // return an *normalized* result vector
    z.normalize();
    return z; // placeholder, you should not return this.
  }


  //-------------------------------------------------------------

  void iniTexture() {

    if (texi == null) {
      texi = createImage(10, 10, RGB);
      for (int i=0; i<texi.width*texi.height; i++) 
        texi.pixels[i]=color(0, 0, 0, 0);
    }

    // _texi has the color of the stroke color c
    // and brightness values (inverse) are mapped to alpha

    float cred = red(col);
    float cgreen = green(col);
    float cblue = blue(col);

    _texi = createImage(texi.width, texi.height, ARGB);
    for (int i=0; i<texi.width*texi.height; i++) {
      float a = 255-brightness(texi.pixels[i]); 
      _texi.pixels[i]=color(cred, cgreen, cblue, a);
    }
  }

  //-------------------------------------------------------------
 //<>//
  public String toString() {
    String s = "Line [";
    for (int i = 1; i<plist.size(); i++) 
      s += plist.get(i).toString();
    s += "] ";
    return s;
  }

  //---------------------------------------------- 

  void movePerpendicuarToGradient(int steps, PImage inp) {
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    color col = inp.get(actX, actY);

    for (int i=0; i<steps; i++) {
      tracePosition(inp);
      actX = (int)round(plist.get(plist.size()-1).x);
      actY = (int)round(plist.get(plist.size()-1).y);
      color actC = inp.get(actX, actY);

      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) 
        + sq(blue(col)-blue(actC))) > 50) 
        break;
    }
  }

  //---------------------------------------------- 

  void tracePosition(PImage inp) {
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    int w = inp.width;

    if (inp == null) return;
    actX = constrain(actX, 1, inp.width-2);
    actY = constrain(actY, 1, inp.height-2);
    
    // Gradient 
    float gx =  fx[0][0] * brightness(inp.pixels[actX-1 + (actY-1)*w]) + fx[0][1] * brightness(inp.pixels[actX + (actY-1)*w]) + fx[0][2] * brightness(inp.pixels[actX+1 + (actY-1)*w]) + 
                fx[1][0] * brightness(inp.pixels[actX-1 + (actY)*w]) + fx[1][1] * brightness(inp.pixels[actX + (actY)*w]) + fx[1][2] * brightness(inp.pixels[actX+1 + (actY)*w]) +
                fx[2][0] * brightness(inp.pixels[actX-1 + (actY+1)*w]) + fx[2][1] * brightness(inp.pixels[actX + (actY+1)*w]) + fx[2][2] * brightness(inp.pixels[actX+1 + (actY+1)*w]);

    float gy =  fy[0][0] * brightness(inp.pixels[actX-1 + (actY-1)*w]) + fy[0][1] * brightness(inp.pixels[actX + (actY-1)*w]) + fy[0][2] * brightness(inp.pixels[actX+1 + (actY-1)*w]) + 
                fy[1][0] * brightness(inp.pixels[actX-1 + (actY)*w]) + fy[1][1] * brightness(inp.pixels[actX + (actY)*w]) + fy[1][2] * brightness(inp.pixels[actX+1 + (actY)*w]) +
                fy[2][0] * brightness(inp.pixels[actX-1 + (actY+1)*w]) + fy[2][1] * brightness(inp.pixels[actX + (actY+1)*w]) + fy[2][2] * brightness(inp.pixels[actX+1 + (actY+1)*w]);

    // Normalize 
    float len = sqrt(sq(gx)+sq(gy));    
    if (len==0) return;

    gx /= len;
    gy /= len;

    // find new postion
    float stepSize = wid/2;
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    plist.add(new PVector(actX+dx, actY+dy));
  }
}
