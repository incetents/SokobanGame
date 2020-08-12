
// Master Button
Button hoveredButton = null;
Button pressedButton = null;
Button draggedButton = null;

//
public enum ButtonType
{
  SQUARE, 
    TRIANGLE
}

//
class Button
{
  public ButtonType type;
  public BoundingBox boundingBox = null;
  public TriangleBox triangleBox = null;
  //private boolean isDragging = false;
  private PVector draggingStart = new PVector(0, 0);
  private PVector dragDelta = new PVector(0, 0);
  private boolean onDragEndEvent = false;

  public Button(ButtonType _type)
  {
    type = _type;
    if (type == ButtonType.SQUARE)
    {
      boundingBox = new BoundingBox(0, 0, 0, 0);
    } else if (type == ButtonType.TRIANGLE)
    {
      triangleBox = new TriangleBox(0, 0, new PVector(-1, 0), new PVector(0, 0), new PVector(0, -1));
    }
  }
  public Button(ButtonType _type, float _x, float _y, PVector a, PVector b, PVector c)
  {
    type = _type;
    if (type == ButtonType.SQUARE)
    {
      boundingBox = new BoundingBox(_x, _y, a.x, a.y);
    } else if (type == ButtonType.TRIANGLE)
    {
      triangleBox = new TriangleBox(_x, _y, a, b, c);
    }
  }

  public boolean isHovered()
  {
    return hoveredButton == this;
  }
  public boolean isPressed()
  {
    return pressedButton == this;
  }
  public boolean isReleased()
  {
    return onDragEndEvent;
  }
  public boolean isReleasedOnButton()
  {
    return onDragEndEvent && hoveredButton == this;
  }

  public boolean onDragEnd()
  {
    return onDragEndEvent;
  }
  public PVector getDragDelta()
  {
    return dragDelta;
  }

  public void setPosition(float x, float y)
  {
    if (boundingBox != null)
    {
      boundingBox.position.x = x;
      boundingBox.position.y = y;
    } else if (triangleBox != null)
    {
      triangleBox.position.x = x;
      triangleBox.position.y = y;
    }
  }
  public void setPosition(PVector pos)
  {
    if (boundingBox != null)
    {
      boundingBox.position.x = pos.x;
      boundingBox.position.y = pos.y;
    } else if (triangleBox != null)
    {
      triangleBox.position.x = pos.x;
      triangleBox.position.y = pos.y;
    }
  }

  public PVector getPosition()
  {
    if (boundingBox != null)
      return boundingBox.position;
    else if (triangleBox != null)
      return triangleBox.position;
    else
      return null;
  }


  public void update()
  {
    onDragEndEvent = false;

    if (boundingBox != null && boundingBox.isMouseOver())
      hoveredButton = this;
    else if (triangleBox != null && triangleBox.isMouseOver())
      hoveredButton = this;

    if (draggedButton == this)
    {
      dragDelta = new PVector(mouseX - draggingStart.x, mouseY - draggingStart.y);
      draggingStart = new PVector(mouseX, mouseY);
    } else
    {
      dragDelta = new PVector(0, 0);
    }

    if (pressedButton == null && hoveredButton == this && mousePressed)
    {
      pressedButton = this;
      if (draggedButton == null)
      {
        draggedButton = this;
        draggingStart = new PVector(mouseX, mouseY);
      }
    } else if (draggedButton == this && !mousePressed)
    {
      draggedButton = null;
      onDragEndEvent = true;
    }
  }

  public void draw(color normal, color hovered)
  {
    //
    if (boundingBox != null)
    {
      if (isHovered() && !mousePressed)
        boundingBox.draw(hovered);
      else
        boundingBox.draw(normal);
    }
    //
    else if (triangleBox != null)
    {
      if (isHovered() && !mousePressed)
        triangleBox.draw(hovered);
      else
        triangleBox.draw(normal);
    }
    //
  }
}
