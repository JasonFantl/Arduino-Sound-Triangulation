class Line {
  float slope;
  float m;
  Line(PVector s, PVector e) {
    slope = (s.y-e.y)/(s.x-e.x);
    m = s.y-(slope*s.x);
  }


  PVector intersects(Line otherL) {
    if(abs(slope - otherL.slope) < 999999) {
    float x = (otherL.m - m)/(slope - otherL.slope);
    float y = slope*x + m;
    return new PVector(x, y);
    }
    else return null;
  }
  void show() {
    PVector s = intersects(new Line(new PVector(0.001, 0), new PVector(0, height)));
    PVector e = intersects(new Line(new PVector(width + 0.001, 0), new PVector(width, height)));
    if(e != null)
    line(s.x, s.y, e.x, e.y);
  }
}
