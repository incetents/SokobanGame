
class GuiWindow
{
  public PVector position;
  public PVector size;
  public PVector minSize;
  public String title;

  private Button nameBar_Btn;
  private Button X_Btn;
  private Button resize_Btn;

  protected BoundingBox foreground;
  protected Viewport viewport_foreground = new Viewport();

  protected boolean close = false;

  public GuiWindow(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    title = _title;
    position = _position;
    size = _size;
    minSize = _minSize;

    nameBar_Btn = new Button(ButtonType.SQUARE);
    X_Btn = new Button(ButtonType.SQUARE);
    resize_Btn = new Button(ButtonType.TRIANGLE, 0, 0, new PVector(-20, 0), new PVector(0, 0), new PVector(0, -20));

    foreground = new BoundingBox(0, 0, size.x - 8, 50);
  }

  public void update()
  {
    // Button Updates
    nameBar_Btn.update();
    X_Btn.update();
    resize_Btn.update();

    // Viewport
    viewport_foreground.setCenter(
      foreground.position.x + foreground.size.x / 2.0, 
      foreground.position.y + foreground.size.y / 2.0
      );
    viewport_foreground.setSize(foreground.size.x, foreground.size.y);

    // Positions
    nameBar_Btn.boundingBox.position = new PVector(position.x + 4, position.y + 4);
    nameBar_Btn.boundingBox.size = new PVector(size.x - 8 - 24, 20);
    X_Btn.boundingBox.position = new PVector(position.x + size.x - 24, position.y + 4);
    X_Btn.boundingBox.size = new PVector(20, 20);
    resize_Btn.triangleBox.position = new PVector(position.x + size.x, position.y + size.y);

    foreground.position = new PVector(position.x + 4, position.y + 4 + 20 + 4);
    foreground.size = new PVector(size.x - 8, size.y - 32);

    // Dragging
    PVector deltaP = nameBar_Btn.getDragDelta();
    position.add(deltaP);
    // Dragging Edge of screen
    if (nameBar_Btn.onDragEnd())
    {
      position.x = constrain(position.x, 0, width - size.x);
      position.y = constrain(position.y, 0, height - size.y);
    }

    // Resize
    PVector deltaS = resize_Btn.getDragDelta();
    size.add(deltaS);
    // Constrain Size
    size.x = max(size.x, minSize.x);
    size.y = max(size.y, minSize.y);

    // Close
    if (X_Btn.isReleased())
    {
      close = true;
    }
  }

  public void draw()
  {
    // BG
    fill(43);
    rect(position.x, position.y, size.x, size.y);

    // Name Bar
    nameBar_Btn.draw(color(64), color(84));
    // Name
    clip(
      nameBar_Btn.getPosition().x + nameBar_Btn.boundingBox.size.x / 2.0, 
      nameBar_Btn.getPosition().y + nameBar_Btn.boundingBox.size.y / 2.0, 
      nameBar_Btn.boundingBox.size.x, 
      nameBar_Btn.boundingBox.size.y
      );
    RenderText(title, nameBar_Btn.getPosition().x + 4, position.y + 4 - getFontHeight() / 2.0, color(255), TEXTH.LEFT, 0.5);
    noClip();

    // Exit Button
    X_Btn.draw(color(180, 0, 0), color(240, 60, 60));
    // Exit Text
    RenderText("X", position.x + size.x - 18, position.y + 4 - getFontHeight() / 2.0, color(0), TEXTH.LEFT, 0.5);

    // FG
    foreground.draw(color(64));
  }

  public void drawResizeButton()
  {
    // Resize Triangle
    resize_Btn.draw(color(126), color(200));
  }
}
