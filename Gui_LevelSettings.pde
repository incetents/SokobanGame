
class Gui_LevelSettings extends GuiWindow
{
  // Data
  Button levelWidth_Sub_Btn = new Button(ButtonType.SQUARE);
  Button levelWidth_Add_Btn = new Button(ButtonType.SQUARE);

  Button levelHeight_Sub_Btn = new Button(ButtonType.SQUARE);
  Button levelHeight_Add_Btn = new Button(ButtonType.SQUARE);

  private float yOffset1 = 75.0;

  //
  public Gui_LevelSettings(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    super(_title, _position, _size, _minSize);

    levelWidth_Sub_Btn.boundingBox.size = new PVector(46, 22);
    levelWidth_Add_Btn.boundingBox.size = new PVector(46, 22);

    levelHeight_Sub_Btn.boundingBox.size = new PVector(46, 22);
    levelHeight_Add_Btn.boundingBox.size = new PVector(46, 22);
  }

  public void update()
  {
    super.update();

    levelWidth_Sub_Btn.update();
    levelWidth_Add_Btn.update();

    levelHeight_Sub_Btn.update();
    levelHeight_Add_Btn.update();

    float xStart = foreground.position.x;
    float yStart = foreground.position.y;

    levelWidth_Sub_Btn.boundingBox.position = new PVector(xStart + 4, yStart + 4 + getFontHeight());
    levelWidth_Add_Btn.boundingBox.position = new PVector(xStart + 4 + 50, yStart + 4 + getFontHeight());

    levelHeight_Sub_Btn.boundingBox.position = new PVector(xStart + 4, yStart + 4 + getFontHeight() + yOffset1);
    levelHeight_Add_Btn.boundingBox.position = new PVector(xStart + 4 + 50, yStart + 4 + getFontHeight() + yOffset1);

    boolean regenMap = false;

    if (levelWidth_Sub_Btn.isReleased())
    {
      if(gameMap.SubWidth())
      regenMap = true;
    }
    //
    else if (levelWidth_Add_Btn.isReleased())
    {
      if(gameMap.AddWidth())
      regenMap = true;
    }
    //
    else if (levelHeight_Sub_Btn.isReleased())
    {
      if(gameMap.SubHeight())
      regenMap = true;
    }
    //
    else if (levelHeight_Add_Btn.isReleased())
    {
      if(gameMap.AddHeight())
      regenMap = true;
    }

    if (regenMap)
    {
      gameMap.UpdateAllSprites();

      // Size of block based on screen size
      AdjustBlockSize(gameMap);
      // Move camera to center
      camera.setPositionToCenterOfMap(gameMap);
    }
  }

  public void draw()
  {
    super.draw();

    if (levelWidth_Sub_Btn.isHovered() && !mousePressed)
      levelWidth_Sub_Btn.draw(color(124));
    else
      levelWidth_Sub_Btn.draw(color(84));

    if (levelWidth_Add_Btn.isHovered() && !mousePressed)
      levelWidth_Add_Btn.draw(color(124));
    else
      levelWidth_Add_Btn.draw(color(84));

    if (levelHeight_Sub_Btn.isHovered() && !mousePressed)
      levelHeight_Sub_Btn.draw(color(124));
    else
      levelHeight_Sub_Btn.draw(color(84));

    if (levelHeight_Add_Btn.isHovered() && !mousePressed)
      levelHeight_Add_Btn.draw(color(124));
    else
      levelHeight_Add_Btn.draw(color(84));

    float xStart = foreground.position.x;
    float yStart = foreground.position.y;
    RenderText("Level Width: " + str(gameMap.m_width), xStart + 4, yStart - getFontHeight() * 0.25, color(255), TEXTH.LEFT, 0.75);

    RenderText("(-)", xStart + 8, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", xStart + 8 + 50, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);

    RenderText("Level Height: " + str(gameMap.m_height), xStart + 4, yStart - getFontHeight() * 0.25 + yOffset1, color(255), TEXTH.LEFT, 0.75);

    RenderText("(-)", xStart + 8, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", xStart + 8 + 50, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
  }
}
