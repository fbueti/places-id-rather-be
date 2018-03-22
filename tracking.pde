PImage img;
import processing.video.*;
import java.util.Map;

color colorToMatch = color(185,98,121);   
float tolerance =    10;                
HashMap<Float, Float[]> touched = new HashMap<Float,Float[]>();

Capture webcam;

void setup() {
  size(1280,720);

  String[] inputs = Capture.list();
  if (inputs.length == 0) {
    println("Couldn't detect any webcams connected!");
    exit();
  }
  webcam = new Capture(this, inputs[0]);
  webcam.start();
  
  float r = random(50);
  if(r<10) img = loadImage("italy.jpg");
  else if(r<20) img = loadImage("to.jpg");
  else if(r<30) img = loadImage("ca.jpg");
  else if(r<40) img = loadImage("roma.jpg");
  else if(r<=50) img = loadImage("venice.jpg");

}

void draw() {
  image(img, 0, 0);
  fill(0);
  noStroke();
  for(float i=0; i<=width; i=i+10){
    for(float j=0; j<=height; j=j+10){  
        if(touched.get(i) != null){
          for(int k=0; k<touched.get(i).length; k++){
            if(!(touched.get(i)[k] == j)){
              ellipse(i, j, 20, 20);
            }
          }
          break;
        }
        else ellipse(i, j, 20, 20);
    }
  }

  if (webcam.available()) {
    webcam.read();
    //image(webcam, 0,0);
    
    PVector first = findColor(webcam, colorToMatch, tolerance);
    
    if (first != null) {
      fill(colorToMatch);
      stroke(255);
      strokeWeight(2);
      ellipse(first.x, first.y, 30,30);
      float xTouched = Math.round((first.x + 5)/ 10.0) * 10.0;
      float yTouched = Math.round((first.y + 5)/ 10.0) * 10.0;
      
      Float[] touchedY = new Float[1];
      touchedY[0] = yTouched;
      if(touched.get(xTouched) != null){
        Float[] yArr = (Float[]) append(touched.get(xTouched), yTouched);
        touched.put(xTouched, yArr);
      }
      else{
        touched.put(xTouched, touchedY);
      }
    }
  }
}


void mousePressed() {
  loadPixels();
  colorToMatch = pixels[mouseY*width+mouseX];
  println(colorToMatch);
}


PVector findColor(PImage in, color c, float tolerance) {
  
  float matchR = c >> 16 & 0xFF;
  float matchG = c >> 8 & 0xFF;
  float matchB = c & 0xFF;
  
  in.loadPixels();
  for (int y=0; y<in.height; y++) {
    for (int x=0; x<in.width; x++) {
      
      // get rgb values for the current pixel
      color current = in.pixels[y*in.width+x];
      float r = current >> 16 & 0xFF;
      float g = current >> 8 & 0xFF;
      float b = current & 0xFF;
      
      if (r >= matchR-tolerance && r <=matchR+tolerance &&
          g >= matchG-tolerance && g <=matchG+tolerance &&
          b >= matchB-tolerance && b <=matchB+tolerance) {
            return new PVector(x, y);
      }
    }
  }
  return null;
}