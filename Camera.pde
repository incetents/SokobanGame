
class Camera
{
  private PVector position = new PVector(0, 0);

  public void setPositionToCenterOfMap(GameMap _gameMap)
  {
    position.y = (height - (BlockSize * _gameMap.m_height)) / 2.0;
    position.x = (width - (BlockSize * _gameMap.m_width)) / 2.0;
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
