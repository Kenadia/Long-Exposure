import processing.video.*;

Movie mov;
float frameRate = 23.98;
int frameCount;
int startFrame = 0;
//first frame always lost since it's black for some reason, so start 1 frame early
int currentFrame = startFrame;
PImage firstSecond;
boolean rendered = false;
PImage sum;
float [][] exposureSum;

void setup() {
  size(1920, 1080, P2D);
  background(0);
  mov = new Movie(this, "input.mov");
  mov.play();
  mov.jump(0);
  mov.pause();
  frameCount = int(mov.duration() * frameRate);
  println("frame count: " + frameCount);
  //firstSecond = blendFrames(0, 1);
  //rendered = true;
  sum = createImage(width, height, RGB);
  exposureSum = new float [width * height][3];
}

PImage blendFrames(int lo, int hi) {
  PImage mix = createImage(width, height, RGB);
  mix.loadPixels();
  for (int i = lo; i < hi; i++) {
    mov.play();
    mov.jump(1.0);
    mov.pause();
    mov.loadPixels();
    for (int j = 0; j < mix.pixels.length; j++) {
      mix.pixels[j] = mov.pixels[j];
    }
  }
  mix.updatePixels();
  return mix;
}

void movieEvent(Movie m) {
  println("movieEvent");
  m.read();
}

void draw() {
  colorMode(RGB, 1.0);
  if (currentFrame < frameCount) {
    mov.play();
    mov.jump((currentFrame++ + 0.5) / frameRate);
    mov.pause();
    if (true || currentFrame == 0) {
      image(mov, 0, 0, width, height);
    } else {
      //blend(mov, 0, 0, width, height, 0, 0, width, height, SCREEN);
    }
    
    /*loadPixels();
    sum.loadPixels();
    screenBlend(sum.pixels, pixels);
    sum.updatePixels();*/
    
    loadPixels();
    addFrame(pixels);
    //background(0);
    image(makeExposure(currentFrame - startFrame - 1), 0, 0, width, height);
    
    saveFrame();
  }
}

// long exposure

void addFrame(color [] frame) {
  for (int i = 0; i < frame.length; i++) {
    exposureSum[i][0] += red(frame[i]);
    exposureSum[i][1] += green(frame[i]);
    exposureSum[i][2] += blue(frame[i]);
  }
}

PImage makeExposure(int frames) {
  PImage exposure = createImage(width, height, RGB);
  for (int i = 0; i < exposure.pixels.length; i++) {
    float r = exposureSum[i][0] / frames;
    float g = exposureSum[i][1] / frames;
    float b = exposureSum[i][2] / frames;
    exposure.pixels[i] = color(r, g, b);
  }
  exposure.updatePixels();
  return exposure;
}

// custom blending modes

void rawSumBlend(color [] base, color [] layer) {
  for (int i = 0; i < base.length; i++) {
    base[i] += layer[i];
  }
}

void screenBlend(color [] base, color [] layer) {
  for (int i = 0; i < base.length; i++) {
      color c = base[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      color c2 = layer[i];
      float r2 = red(c2);
      float g2 = green(c2);
      float b2 = blue(c2);
      float rn = 1 - (1 - r) * (1 - r2);
      float gn = 1 - (1 - g) * (1 - g2);
      float bn = 1 - (1 - b) * (1 - b2);
      color cn = color(rn, gn, bn);
      base[i] = cn;
  }
}

void exposureBlend(color [] base, color [] layer) {
  for (int i = 0; i < base.length; i++) {
      color c = base[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      color c2 = layer[i];
      float r2 = red(c2);
      float g2 = green(c2);
      float b2 = blue(c2);
      float rn = 1 - sqrt((1 - r) * (1 - r2));
      float gn = 1 - sqrt((1 - g) * (1 - g2));
      float bn = 1 - sqrt((1 - b) * (1 - b2));
      color cn = color(rn, gn, bn);
      base[i] = cn;
  }
}
