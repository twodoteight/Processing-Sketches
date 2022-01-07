PImage method(PImage img, PImage depth) {
  
  PImage res = img.copy();
  PImage blurred = depth.copy();
  PImage mask = depth.copy();
  
  blurred.filter(BLUR, 15);
  mask.blend(blurred, 0, 0, img.width, img.height, 0, 0, depth.width, depth.height, SUBTRACT);
  
  PImage innerMask = blurred.copy();
  innerMask.blend(depth, 0, 0, img.width, img.height, 0, 0, depth.width, depth.height, SUBTRACT);

  mask.loadPixels();
  for (int i=0; i<res.width*res.height; i++) {
    float br = brightness(mask.pixels[i]);
    if(mask.pixels[i]!=black)
    mask.pixels[i] = color(0,br*0.2,br);
  }
  mask.updatePixels();
  
  innerMask.loadPixels();
  for (int i=0; i<res.width*res.height; i++) {
    float br = brightness(innerMask.pixels[i]);
    if(innerMask.pixels[i]!=black)
    innerMask.pixels[i] = color(0,br,br);
  }
  innerMask.updatePixels();
  
  res.blend(mask, 0, 0, img.width, img.height, 0, 0, depth.width, depth.height, SUBTRACT);
  res.blend(innerMask, 0, 0, img.width, img.height, 0, 0, depth.width, depth.height, SUBTRACT);

//img.loadPixels();
//  for (int i=0; i<res.width*res.height; i++) {
//    if(res.pixels[i]!=white && img.pixels[i]!=white)
//      res.pixels[i] = img.pixels[i];
//  }
//  res.updatePixels();
  //img.blend(res, 0,0,img.width,img.height,0,0,depth.width,depth.height, ADD);

  return res;
}

color intToColor(int i) {
  int r = i & 0xFF;
  int g = (i>>8) & 0xFF;
  int b = (i>>16) & 0xFF;
  return color(r, g, b);
}

int colorToInt(color c) {
  int r = (int)(c>> 16 & 0xFF);
  int g = (int)(c>> 8 & 0xFF);
  int b = (int)(c & 0xFF);
  return r + (g<<8) + (b<<16);
}
