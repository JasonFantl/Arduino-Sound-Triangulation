//NEEDS TO BE REFACTORED, IS TERRIBLAY
import processing.serial.*;
Serial myPort;  // Create object from Serial class

double speedOSound = 343;

ArrayList<listener> listeners = new ArrayList<listener>();
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<PVector> intersects = new ArrayList<PVector>();
int initialDis = 0;

PVector soundSpot = new PVector(10, 10);
void setup() {
  size(600, 600, P3D);
  try {
    myPort = new Serial(this, "COM4", 2000000);
  } 
  catch (Exception e) {
    println("failed to open COM");
    //e.printStackTrace();
  }
  noStroke();
  listeners.add(new listener(width/2 - 200, 100));
  listeners.add(new listener(width/2 - 200, height-100));


  //USER INPUT
  /////////////////////////////////////////////////////////////////////////////////////////////
  //make sure each listener is added in order that the sensors are attached, starting from A2, moving to A3
  initialDis = 142; //make distance between two first listeners (inchs)
  addListener(142, 162, false); //distance from listener 1, distance from listener 2, is to the left
  //addListener(120, 150, false); //distance from listener 1, distance from listener 2, is to the left

  ///////////////////////////////////////////////////////////////////////////
}

String val = "";

void draw() {
  if (mousePressed) {
    soundSpot = new PVector(mouseX, mouseY);
    for (listener l : listeners) {
      l.timeSince = soundSpot.dist(l.pos)/speedOSound;
      //println(l.pos.toString() + ", time to reach: " + l.timeSince);
    }
    updateListeners();
  }


  try {
    while (myPort.available() > 0) {  // If data is available,
      val += myPort.readString();         // read it and store it in val
    }
  }
  catch(Exception e) {
    //e.printStackTrace();
  }
  if (val != "") {
    int[] nums = int(split(val, ','));
    if (nums.length == listeners.size()) { //makes sure data is complete
      for (int i = 0; i < nums.length; i++) {
        listeners.get(i).timeSince = nums[i] / 10000.0; //assign new values to listeners
        print(listeners.get(i).timeSince + ",");
      }
      println();
      updateListeners();
    }
  }
}

void updateListeners() {

  //find closest
  listener closest = listeners.get(0);
  for (listener l : listeners) {
    if (l.timeSince < closest.timeSince) closest = l;
  }
  //set radius
  for (listener l : listeners) {
    l.radius = (l.timeSince - closest.timeSince) * speedOSound;
  }
  while (!allCircleOverlapping()) {
    for (listener l : listeners) {
      l.radius++;
    }
  }
  background(51);
  fill(0);
  ellipse(soundSpot.x, soundSpot.y, 10, 10);
  lines = findLinesFromCircles();
  intersects.clear();
  for (int i = 0; i < lines.size() - 1; i++) {
    for (int j = i + 1; j < lines.size(); j++) {
      PVector intersect = lines.get(i).intersects(lines.get(j));
      if (intersect != null) {
        intersects.add(intersect.copy());
      }
    }
  }
  fill(10, 112);

  for (listener l : listeners) {
    l.show();
  }
  fill(255, 255);
  stroke(10);
  strokeWeight(0.5);
  for (Line l : lines) {
    l.show();
  }
  noStroke();


  fill(250, 250);

  PVector predict = new PVector(0, 0);
  int divSize = 0;
  for (PVector p : intersects) {
    if (p != null) {
      predict.add(p.copy());
      divSize++;
    }
  }
  predict.div(divSize);
  ellipse(predict.x, predict.y, 10, 10);
  //println("predict: " + predict.x + " " + predict.y);
}

boolean allCircleOverlapping() {
  for (listener l1 : listeners) {
    for (listener l2 : listeners) {
      if (l1 != l2) {
        if (l1.pos.dist(l2.pos) >= l1.radius + l2.radius) return false;
      }
    }
  }
  return true;
}

ArrayList<Line> findLinesFromCircles() {
  ArrayList<Line> finalLines = new ArrayList<Line>();
  for (int i = 0; i < listeners.size(); i++) {
    listener c1 = listeners.get(i);
    for (int j = i + 1; j < listeners.size(); j++) {
      listener c2 = listeners.get(j);

      double D = sqrt(pow(c2.pos.x-c1.pos.x, 2) + pow(c2.pos.y-c1.pos.y, 2));
      double alpha = 0.25*sqrt((float)((D+c1.radius+c2.radius)*(D+c1.radius-c2.radius)*(D-c1.radius+c2.radius)*(-D+c1.radius+c2.radius)));
      double baseX = (c1.pos.x+c2.pos.x)/2 + ((c2.pos.x-c1.pos.x)*(pow((float)c1.radius, 2)-pow((float)c2.radius, 2))/(2*pow((float)D, 2)));
      double offsetX = 2*alpha*(c1.pos.y-c2.pos.y)/pow((float)D, 2);
      double baseY = (c1.pos.y+c2.pos.y)/2 + (c2.pos.y-c1.pos.y)*(pow((float)c1.radius, 2)-pow((float)c2.radius, 2))/(2*pow((float)D, 2));
      double offsetY = 2*alpha*(c1.pos.x-c2.pos.x)/pow((float)D, 2);

      finalLines.add(new Line(new PVector((float)(baseX-offsetX), (float)(baseY+offsetY)), new PVector((float)(baseX+offsetX), (float)(baseY-offsetY))));
    }
  }
  return finalLines;
}


void addListener(int dis2, int dis1, boolean toTheLeft) {
  double scl = abs(listeners.get(1).pos.y - listeners.get(0).pos.y)/initialDis;
  double x = 0;
  double y = 0;
  float a = acos((pow(initialDis, 2) + pow(dis2, 2) - pow(dis1, 2))/(2*dis2*initialDis));
  x = sin(a) * dis2 * scl;
  y = cos(a) * dis2 * scl;
  if (toTheLeft) x = -x;
  listeners.add(new listener((int)(x + listeners.get(0).pos.x), (int)(y + listeners.get(0).pos.y)));
}
