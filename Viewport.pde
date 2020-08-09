
class Viewport
{
  public PVector center;
  public PVector size;

  public Viewport()
  {
    center = new PVector(0, 0);
    size = new PVector(0, 0);
  }
  public Viewport(PVector _center, PVector _size)
  {
    center = _center;
    size = _size;
  }

  public void setCenter(PVector _center)
  {
    center = _center;
  }
  public void setCenter(float _x, float _y)
  {
    center = new PVector(_x, _y);
  }

  public void setSize(PVector _size)
  {
    size = _size;
  }
  public void setSize(float _w, float _h)
  {
    size = new PVector(_w, _h);
  }
  
  public void bind()
  {
    clip(center.x, center.y, size.x, size.y);
  }
  
  public boolean isMouseInside()
  {
    float halfW = size.x / 2.0;
    float halfH = size.y / 2.0;
    return mouseX >= (center.x - halfW) && mouseX <= (center.x + halfW) && mouseY >= (center.y - halfH) && mouseY <= (center.y + halfH);
  }
}

public void unbindViewport()
{
  noClip();
}
