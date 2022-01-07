ArrayList<Point> p,vp; // p is the array of points making up the geometry
ArrayList<Triangle> t; // triangles forming the geometry (computed from p)
ArrayList<Line> l;

float rotationX = 72f;
float rotationY = -80f;
float scalef = 80;
float epsilon = 0.03; 

// Flags for showing certain point properties
int drawMode=0;
boolean showNormals = false;
boolean showEigenVectors = false; 
boolean showSilhouette = false;

PVector viewv = new PVector(-1,-1,-0.2);

color cblack=color(0,0,0);
color cwhite=color(255,255,255);
color cbackground =color(222,195,63);
color clightgray=color(150,150,150);
color cdarkgray=color(70,70,70);

//////////////////////////////////////////////////

class Point {
 float x,y,z;
 float nx,ny,nz;
 int nn;
 color c;
 
 Point() { x=y=z=0; nx=ny=nz=0; nn=0; c=color(0,0,0); }
 Point(float px,float py,float pz, color pc) {
   x=px;y=py;z=pz;
   c=pc;
 }
 Point(Point p) {
   x=p.x;y=p.y;z=p.z;
   nx=p.nx;ny=p.ny;nz=p.nz;
   c=p.c;
 }
 
 void setNormal(float px, float py, float pz) { nx=px; ny=py; nz=pz; }
 void addNormal(float px, float py, float pz) { nx+=px; ny+=py; nz+=pz; nn++;}
 void resolveNormal() { nx/=nn; ny/=nn; ny/=nn; }
}


///////////////////////////////////////////////////////////////

class Triangle {
  int p1,p2,p3;
  float nx,ny,nz;
 
  Triangle() { p1=p2=p3=-1; }
  Triangle(int pp1,int pp2, int pp3) {p1=pp1; p2=pp2; p3=pp3;}
  Triangle(Triangle t) {p1=t.p1; p2=t.p2; p3=t.p3; }

  void setNormal(float px, float py, float pz) { nx=px; ny=py; nz=pz; }
}

///////////////////////////////////////////////////////////////

class Line {
  float x1,y1,z1,x2,y2,z2;
   color c;
 
  Line() { x1=x1=y1=y2=z1=z2=0; }
  Line(float px1, float py1, float pz1, float px2, float py2, float pz2, color pc) 
      { x1 = px1; y1=py1; z1=pz1; x2=px2; y2=py2; z2=pz2; c = pc; }
  Line(Line l) {x1=l.x1; x2=l.x2; y1=l.y1; y2=l.y2;  z1=l.z1; z2=l.z2; c=l.c; }
}

//////////////////////////////////////////////////////

// Functions defining the plane, along with the (partial) derivatives. Having these functions
// allows us to search local minim a in the gradients, which cannot be done easily in discrete
// geometry.

float f(float x, float y) { return sin(0.15*(sq(x)+5*y)); }
float dxf(float x, float y) { return 3*x*cos(0.15*(sq(x)+5*y))/10; }
float dyf(float x, float y) { return 3*cos(0.15*(sq(x)+5*y))/4; }
float dxxf(float x, float y) { return -9*sq(x)*sin(0.15*(sq(x)+5*y))/100 + 3*cos(0.15*(sq(x)+5*y))/10; }
float dxyf(float x, float y) { return -9*x*sin(0.15*(sq(x)+5*y))/40; }
float dyxf(float x, float y) { return -9*x*sin(0.15*(sq(x)+5*y))/40; }
float dyyf(float x, float y) { return -9*sin(0.15*(x*x+5*y))/16; }

/////////////////////////////////////////////////

// trace and determinat of matrix with partial derivations

float trace(float x, float y) { return dxxf(x,y)+dyyf(x,y);  }

float det(float x, float y) { return dxxf(x,y)*dyyf(x,y) - dxyf(x,y)*dyxf(x,y); }

// first and second eigenvalue (principal curvature) of matrix with 
// partial derivations

float kappa_1(float x, float y) { return trace(x,y)/2 + sqrt(sq(trace(x,y))/4-det(x,y)); }

float kappa_2(float x, float y) { return trace(x,y)/2 - sqrt(sq(trace(x,y))/4-det(x,y)); }

// normal vector and product with view vector (defined globally)

PVector normalVector(float x, float y) {
      PVector norm = new PVector(-dxf(x,y),-dyf(x,y),1);
      norm.normalize();
      return norm;
}

// Dot product of normal and view vector at point (x,y).
float nv(float x, float y) {
      PVector norm = new PVector(-dxf(x,y),-dyf(x,y),1);
      norm.normalize();
      return viewv.dot(norm);
} 

/////////////////////////////////////////////////

void generateGeometry() {
  float u0=-5,v0=-5;
  float u1=5, v1=5;
  float r=100,g=100,b=100;
  int wid=100;

  t.clear();
  p.clear();

  float du=(u1-u0)/wid;
  float dv=(v1-v0)/wid;
  for (int k=0; k<wid; k++) 
    for (int i=0; i<wid; i++) {
      float u = u0+i*du;
      float v = v0+k*dv;
      float val = f(u,v);
      // TODO: Fill in these cases.
      switch (drawMode) {
        case 1: // colorize according to partial derivations
                r = dxf(u, v)*255;
                g = 0;
                b = dxf(u,v)*255;
                break;
        case 2: // colorize according to mean curvature
                float H = (kappa_1(u,v)+kappa_2(u,v))/2;
                r = 10/abs(H);
                g = 0;
                b = 0; 
                break;
        case 3: // colorize according to Gaussian curvature
                float K = kappa_1(u,v)*kappa_2(u,v);
                r = 3/abs(K);
                g = 0;
                b = 0; 
                break;
        case 4: // colorize according to n*v value (for silhouettes)
                float nv = nv(u,v);
                r = b = 255*abs(nv);
                g = 0;
                break;
      }
      p.add(new Point(u,v,val,color(r,g,b)));  
      if ((i>0) && (k>0)) {
         t.add(new Triangle(i+k*wid,(i-1)+k*wid,(i-1)+(k-1)*wid));
         t.add(new Triangle(i+(k-1)*wid,i+k*wid,(i-1)+(k-1)*wid));
      }
  }
}

///////////////////////////////////////////////////

void generateLines() {

  float u0=-5,v0=-5;
  float u1=5, v1=5;
  int wid=100;
  
  // eigenvectors
  PVector ev1,ev2; 
  
  l.clear();
  
  float du=(u1-u0)/wid;
  float dv=(v1-v0)/wid;
  for (int k=0; k<wid; k++) 
    for (int i=0; i<wid; i++) {
      float u = u0+i*du;
      float v = v0+k*dv;
      float f = f(u,v);
      float a = dxxf(u,v);
      float b = dxyf(u,v);
      float c = dyxf(u,v);
      float d = dyyf(u,v);
      float k1 = kappa_1(u,v);
      float k2 = kappa_2(u,v);
      
      if (c != 0)
      { ev1 = new PVector(k1-d,c); 
        ev2 = new PVector(k2-d,c);
      } else {
        ev1 = new PVector(b,k1-a);
        ev2 = new PVector(b,k2-a);
      }
      ev1.normalize();
      ev2.normalize();
      if ((showEigenVectors) && (i % 5==0) && (k%5 == 0)) {
        l.add(new Line(u,v,f,u+0.2*ev1.x,v+0.2*ev1.y,f,color(255,255,255)));
        l.add(new Line(u,v,f,u+0.2*ev2.x,v+0.2*ev2.y,f,color(255,255,255)));
      }
      PVector norm = normalVector(u,v);
      if ((showNormals) && (i % 5==0) && (k%5 == 0)) {
        l.add(new Line(u,v,f,u+0.3*norm.x,v+0.3*norm.y,f+0.3*norm.z,color(255,255,255)));
      }
      if (showSilhouette) {
                // TODO
        float nv = nv(u,v);
        if(nv>0 && nv<epsilon) {
          l.add(new Line(u,v,f,u+0.3*norm.x,v+0.3*norm.y,f+0.3*norm.z,color(255,255,255)));
        }
      }
   }
}
  
///////////////////////////////////////////////////

void generateVisiblePoints() {

  float u0=-5,v0=-5;
  float u1=5, v1=5;
  int wid=20;
  
  vp.clear();
  
  float du=(u1-u0)/wid;
  float dv=(v1-v0)/wid;
  for (int k=0; k<wid; k++) 
    for (int i=0; i<wid; i++) {
      float u = u0+i*du;
      float v = v0+k*dv;
      float f = f(u,v);
      vp.add(new Point(u,v,f,color(255,255,255)));
    }
}
 
///////////////////////////////////////////////////

void moveVisiblePoints() {

  float dx = 0.1;
  float dy = 0.1;
  float stepSize = 0.1;
  
  for (int i=0;i<vp.size();i++) {
    
        Point pt = (Point)vp.get(i);
        float x = pt.x;
        float y = pt.y; 
        dx = nv(x-1,y) - nv(x+1,y);
        dy = nv(x,y-1) - nv(x,y+1);
        norm(dx,dy,0);
        
        pt.x=x+stepSize*dx;
        pt.y=y+stepSize*dy;
        pt.z=f(x,y);
        // TODO
        
   }      
}

/////////////////////////////////////////////////////////////////////

void drawGeometry() {
  noStroke();
  beginShape(TRIANGLES);
    for (int i=0;i<t.size();i++) {
      Triangle tri = (Triangle)t.get(i);
      Point p1 = (Point)p.get(tri.p1);
      Point p2 = (Point)p.get(tri.p2);
      Point p3 = (Point)p.get(tri.p3);
      fill(p1.c);
      normal(p1.nx,p1.ny,p1.nz);
      vertex(p1.x,p1.y,p1.z);
      fill(p2.c);
      normal(p2.nx,p2.ny,p2.nz);
      vertex(p2.x,p2.y,p2.z);
      fill(p3.c);
      normal(p3.nx,p3.ny,p3.nz);
      vertex(p3.x,p3.y,p3.z);
   }
  endShape();
  
  stroke(255,255,255);
  strokeWeight(0.01);
  beginShape(LINES);
      for (int i=0;i<l.size();i++) {
        Line li = (Line)l.get(i);
        stroke(li.c);
        vertex(li.x1,li.y1,li.z1);
        vertex(li.x2,li.y2,li.z2);
      }
  endShape();
  
  // visible Points for silhouettes
  noStroke();
  sphereDetail(3);
  for (int i=0;i<vp.size();i++) {
        Point pt = (Point)vp.get(i);
        fill(pt.c);
        pushMatrix();
        translate(pt.x,pt.y,pt.z);
        sphere(0.03);
        popMatrix();
  } 
}

/////////////////////////////////////////////////////////////////////

void computeNormals(ArrayList points,ArrayList triangles) {
  for (int i=0;i<triangles.size();i++) {
    Triangle tri = (Triangle)triangles.get(i);
    Point p1 = (Point)points.get(tri.p1);
    Point p2 = (Point)points.get(tri.p2);
    Point p3 = (Point)points.get(tri.p3);
    PVector pa = new PVector(p2.x-p1.x,p2.y-p1.y,p2.z-p1.z);
    PVector pb = new PVector(p2.x-p3.x,p2.y-p3.y,p2.z-p3.z);
    pa.normalize();
    pb.normalize();
    PVector n = pb.cross(pa);
    tri.setNormal(n.x,n.y,n.z);
  }
}

/////////////////////////////////////////////////////////////////////

void smoothNormals(ArrayList points,ArrayList triangles) {
  for (int i=0;i<points.size();i++) {
      Point p = (Point)points.get(i);
      p.setNormal(0,0,0);
  }
  for (int i=0;i<triangles.size();i++) {
    Triangle tri = (Triangle)triangles.get(i);
    Point p1 = (Point)points.get(tri.p1);
    Point p2 = (Point)points.get(tri.p2);
    Point p3 = (Point)points.get(tri.p3);
    p1.addNormal(tri.nx,tri.ny,tri.nz);
    p2.addNormal(tri.nx,tri.ny,tri.nz);
    p3.addNormal(tri.nx,tri.ny,tri.nz);
  }
  for (int i=0;i<points.size();i++) {
      Point p = (Point)points.get(i);
      p.resolveNormal();
  }  
}

//////////////////////////////////////////////////

void generateAll() {
  generateGeometry();  
  computeNormals(p,t);
  smoothNormals(p,t);
  generateLines();
}

////////////////////////////////////////////////////

void setup() {
  size(1200,1000,P3D);  
  colorMode(RGB,255,255,255);
  ortho();
  
  p = new ArrayList<Point>(10000);
  t = new ArrayList<Triangle>(10000);
  l = new ArrayList<Line>(10000);
  vp = new ArrayList<Point>(10000);

  viewv.normalize();

  generateAll();
  generateVisiblePoints();

  noLoop();
}

/////////////////////////////////////////////////////////////////

void draw() {
  
  background(cbackground);

  noStroke();
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
 
  directionalLight(255, 255, 255, 0,0, -0.3); 
  ambientLight(100,100,100);

  translate(width/2,height/2,-height/2);
  scale(scalef,scalef,scalef);
  rotateX(radians(rotationX));
  rotateZ(radians(rotationY));
  strokeWeight(0.01);
  // x-axis red
  stroke(255,0,0);
  line(0,0,1,4,0,1);
  // y-axis green
  stroke(0,255,0);
  line(0,0,1,0,4,1);
  // z-axis blue
  stroke(0,0,255);
  line(0,0,1,0,0,5);
  
  if (showSilhouette) {
    stroke(255,255,255);
    line(0,0,1,viewv.x,viewv.y,1+viewv.z);
  }
  
  drawGeometry();

}

////////////////////////////////////////////////////////////////

void keyPressed() {
  if (key=='+') scalef*=1.2;
  if (key=='-') scalef/=1.2;
  
  if (key=='0') drawMode = 0; // Justa grey color
  if (key=='1') drawMode = 1; // red and blue channels according to partial derivations
  if (key=='2') drawMode = 2; // red channel filled according to mean curvature
  if (key=='3') drawMode = 3; // red channel filled according to Gaussian curvature
  if (key=='4') drawMode = 4; // n*v value

  if (key=='n') showNormals = !showNormals; 
  if (key=='e') showEigenVectors = !showEigenVectors;
  if (key=='s') showSilhouette = !showSilhouette; 
  
  if (key=='x') { viewv.x += 0.1; }
  if (key=='y') { viewv.y += 0.1; }
  if (key=='z') { viewv.z += 0.1; }
  if (key=='g') { viewv.x -= 0.1; }
  if (key=='h') { viewv.y -= 0.1; }
  if (key=='j') { viewv.z -= 0.1; }

  if (key== 'm') moveVisiblePoints();
  
  if (key=='o') { save("output.png"); } 

  if (key == CODED) {
    if (keyCode == UP) {scalef*=1.2;} else
     if (keyCode == DOWN) {scalef/=1.2;} else
      if (keyCode == RIGHT) {epsilon += 0.01;} else
       if (keyCode == LEFT) {epsilon -= 0.01; epsilon = max(0,epsilon); } 
  }
  
  generateAll();
  redraw();
}

//////////////////////////////////////////////////////////////////

void mouseDragged() {
    rotationY = (mouseX-width/2)/3;
    rotationX = (height/2-mouseY)/3;
    redraw();
}
  
