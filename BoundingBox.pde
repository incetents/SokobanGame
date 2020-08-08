
class TriangleBox
{
  public PVector position;

  private PVector p1;
  private PVector p2;
  private PVector p3;

  private PShape triangle;

  public TriangleBox(float _x, float _y, PVector _p1, PVector _p2, PVector _p3)
  {
    position = new PVector(_x, _y);
    p1 = _p1;
    p2 = _p2;
    p3 = _p3;

    triangle = createShape();
    triangle.beginShape(TRIANGLES);
    triangle.noStroke();

    triangle.vertex(p1.x, p1.y);
    triangle.vertex(p2.x, p2.y);
    triangle.vertex(p3.x, p3.y);

    triangle.endShape();
  }

  public boolean isMouseOver()
  {
    return PointInTriangle(
      new PVector(mouseX, mouseY), 
      new PVector(p1.x + position.x, p1.y + position.y), 
      new PVector(p2.x + position.x, p2.y + position.y), 
      new PVector(p3.x + position.x, p3.y + position.y)
      );
  }

  public void draw(color c)
  {
    push();
    translate(position.x, position.y);
    triangle.setFill(c);
    shape(triangle);
    pop();
  }
}

class BoundingBox
{
  public PVector position;
  public PVector size;

  public BoundingBox(float _x, float _y, float _w, float _h)
  {
    position = new PVector(_x, _y);
    size = new PVector(_w, _h);
  }

  public boolean isMouseOver()
  {
    return mouseX >= (position.x) && mouseX <= (position.x + size.x) && mouseY >= (position.y) && mouseY <= (position.y + size.y);
  }

  public void draw(color c)
  {
    fill(c);
    rect(position.x, position.y, size.x, size.y);
  }
}
