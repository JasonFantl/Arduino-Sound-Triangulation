class listener {

  double timeSince = 0;
  PVector pos;
  double radius;
  //likely need an offset to synk all of thwm together

  listener(int x, int y) {
    pos = new PVector(x, y);
    radius = 300;
  }

  void show() {
    fill(200);
    ellipse(pos.x, pos.y, 10, 10);

    fill(200, 100);
    ellipse(pos.x, pos.y, (float)radius*2, (float)radius*2);
    noFill();
  }
}
