
class Camera
{
  private PVector position = new PVector(0, 0);

  public void setPositionToCenterOfMap(GameMap _gameMap)
  {
    if (_gameMap.m_width * BlockSize >= width)
    {
      // Vertical Fix
      float y_offset = height - (BlockSize * _gameMap.m_height);
      position.x = 0;
      position.y = (round(y_offset / 2.0));
    }
    //
    else
    {
      // Horizontal Fix
      float x_offset = width - (BlockSize * _gameMap.m_width);
      position.x = (round(x_offset / 2.0));
      position.y = 0;
    }
  }

  public void setPosition(float _x, float _y)
  {
    position.x = _x;
    position.y = _y;
  }
  public void setX(float _x) {
    position.x = _x;
  }
  public void setY(float _y) {
    position.y = _y;
  }

  public PVector getPosition()
  {
    return position;
  }
  public float getX() { 
    return position.x;
  }
  public float getY() {
    return position.y;
  }
}
