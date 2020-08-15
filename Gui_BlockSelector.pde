
class Gui_BlockSelector extends GuiWindow
{
  // Data
  private final float ButtonBlockSize = 64;
  private final float ButtonBlockSize_Half = ButtonBlockSize / 2.0;
  private int ButtonRowCount = 1;
  private PVector Selection = new PVector(0, 0);
  private int SelectionIndex = 0;

  //
  public Gui_BlockSelector(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    super(_title, _position, _size, _minSize);
  }

  public void update()
  {
    super.update();

    ButtonRowCount = floor(foreground.size.x / ButtonBlockSize);

    if (viewport_foreground.isMouseInside())
    {
      Selection.x = min(ButtonRowCount - 1, floor((mouseX - foreground.position.x) / ButtonBlockSize));
      Selection.y = floor((mouseY - foreground.position.y) / ButtonBlockSize);
      // Selection to Index
      SelectionIndex = int(Selection.x) + int(Selection.y) * ButtonRowCount;

      if (mousePressed && SelectionIndex < Editor.BlockDrawList.size())
      {
        Editor.SetBlockDrawIndex(SelectionIndex);
      }
    }
  }

  public void draw()
  {
    super.draw();

    viewport_foreground.bind();

    int rowCount = 0;
    float y_offset = 0;

    for (int i = 0; i < Editor.BlockDrawList.size(); i++)
    {
      String spriteIndex = Editor.BlockDrawSpriteList.get(i);
      Sprite sprite = SpriteMap.get(spriteIndex);

      if (rowCount == ButtonRowCount)
      {
        rowCount = 0;
        y_offset += ButtonBlockSize;
      }

      image(
        sprite.image, 
        foreground.position.x + (ButtonBlockSize * rowCount) + ButtonBlockSize_Half, foreground.position.y + ButtonBlockSize_Half + y_offset, 
        ButtonBlockSize, ButtonBlockSize);

      rowCount++;
    }

    // Selection
    if (viewport_foreground.isMouseInside() && SelectionIndex < Editor.BlockDrawList.size())
    {
      stroke(255, 0, 0);
      if (mousePressed)
        fill(255, 0, 0, 50);
      else
        noFill();
      rect(foreground.position.x + Selection.x * ButtonBlockSize, foreground.position.y + Selection.y * ButtonBlockSize, ButtonBlockSize, ButtonBlockSize);
      noStroke();
    }

    unbindViewport();
  }
}
