
class Gui_LevelSettings extends GuiWindow
{
  // Data
  Button levelWidth_Sub_L_Btn = new Button(ButtonType.SQUARE);
  Button levelWidth_Add_L_Btn = new Button(ButtonType.SQUARE);
  Button levelWidth_Sub_R_Btn = new Button(ButtonType.SQUARE);
  Button levelWidth_Add_R_Btn = new Button(ButtonType.SQUARE);

  Button levelHeight_Sub_L_Btn = new Button(ButtonType.SQUARE);
  Button levelHeight_Add_L_Btn = new Button(ButtonType.SQUARE);
  Button levelHeight_Sub_R_Btn = new Button(ButtonType.SQUARE);
  Button levelHeight_Add_R_Btn = new Button(ButtonType.SQUARE);

  Button clearLevel_Btn = new Button(ButtonType.SQUARE);

  private float yOffset1 = 70.0;

  //
  public Gui_LevelSettings(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    super(_title, _position, _size, _minSize);

    levelWidth_Sub_L_Btn.boundingBox.size = new PVector(46, 22);
    levelWidth_Add_L_Btn.boundingBox.size = new PVector(46, 22);
    levelWidth_Sub_R_Btn.boundingBox.size = new PVector(46, 22);
    levelWidth_Add_R_Btn.boundingBox.size = new PVector(46, 22);

    levelHeight_Sub_L_Btn.boundingBox.size = new PVector(46, 22);
    levelHeight_Add_L_Btn.boundingBox.size = new PVector(46, 22);
    levelHeight_Sub_R_Btn.boundingBox.size = new PVector(46, 22);
    levelHeight_Add_R_Btn.boundingBox.size = new PVector(46, 22);

    clearLevel_Btn.boundingBox.size = new PVector(60, 22);
  }

  public void update()
  {
    super.update();

    levelWidth_Sub_L_Btn.update();
    levelWidth_Add_L_Btn.update();
    levelWidth_Sub_R_Btn.update();
    levelWidth_Add_R_Btn.update();

    levelHeight_Sub_L_Btn.update();
    levelHeight_Add_L_Btn.update();
    levelHeight_Sub_R_Btn.update();
    levelHeight_Add_R_Btn.update();

    clearLevel_Btn.update();

    float xStart = foreground.position.x;
    float yStart = foreground.position.y;

    levelWidth_Sub_L_Btn.boundingBox.position = new PVector(xStart + 30, yStart + 4 + getFontHeight());
    levelWidth_Add_L_Btn.boundingBox.position = new PVector(xStart + 80, yStart + 4 + getFontHeight());

    levelWidth_Sub_R_Btn.boundingBox.position = new PVector(xStart + 190, yStart + 4 + getFontHeight());
    levelWidth_Add_R_Btn.boundingBox.position = new PVector(xStart + 240, yStart + 4 + getFontHeight());

    levelHeight_Sub_L_Btn.boundingBox.position = new PVector(xStart + 30, yStart + 4 + getFontHeight() + yOffset1);
    levelHeight_Add_L_Btn.boundingBox.position = new PVector(xStart + 80, yStart + 4 + getFontHeight() + yOffset1);

    levelHeight_Sub_R_Btn.boundingBox.position = new PVector(xStart + 190, yStart + 4 + getFontHeight() + yOffset1);
    levelHeight_Add_R_Btn.boundingBox.position = new PVector(xStart + 240, yStart + 4 + getFontHeight() + yOffset1);

    clearLevel_Btn.boundingBox.position = new PVector(xStart + 4, yStart + 4 + getFontHeight() + yOffset1 * 2);

    boolean regenMap = false;

    if (levelWidth_Sub_L_Btn.isReleased())
    {
      if (gameMap.SubWidth())
        regenMap = true;
    }
    //
    else if (levelWidth_Add_L_Btn.isReleased())
    {
      if (gameMap.AddWidth())
        regenMap = true;
    }
    //
    else if (levelHeight_Sub_L_Btn.isReleased())
    {
      if (gameMap.SubHeight())
        regenMap = true;
    }
    //
    else if (levelHeight_Add_L_Btn.isReleased())
    {
      if (gameMap.AddHeight())
        regenMap = true;
    }
    //
    else if (clearLevel_Btn.isReleased())
    {
      gameMap.clear();
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

    //
    viewport_foreground.bind();

    levelWidth_Sub_L_Btn.draw(color(84), color(124));
    levelWidth_Add_L_Btn.draw(color(84), color(124));
    levelWidth_Sub_R_Btn.draw(color(84), color(124));
    levelWidth_Add_R_Btn.draw(color(84), color(124));

    levelHeight_Sub_L_Btn.draw(color(84), color(124));
    levelHeight_Add_L_Btn.draw(color(84), color(124));
    levelHeight_Sub_R_Btn.draw(color(84), color(124));
    levelHeight_Add_R_Btn.draw(color(84), color(124));

    clearLevel_Btn.draw(color(84), color(124));

    float xStart = foreground.position.x;
    float yStart = foreground.position.y;
    //
    RenderText("Level Width: " + str(gameMap.m_width), xStart + 4, yStart - getFontHeight() * 0.25, color(255), TEXTH.LEFT, 0.75);

    RenderText("L", xStart + 8, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("(-)", levelWidth_Sub_L_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", levelWidth_Add_L_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("R", xStart + 8 + 160, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("(-)", levelWidth_Sub_R_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", levelWidth_Add_R_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75, color(255), TEXTH.LEFT, 0.75);

    fill(43);
    rect(xStart, yStart + 44 - (getFontHeight() * 0.75) + 40, foreground.size.x, 5);

    //
    RenderText("Level Height: " + str(gameMap.m_height), xStart + 4, yStart - getFontHeight() * 0.25 + yOffset1, color(255), TEXTH.LEFT, 0.75);

    RenderText("L", xStart + 8, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("(-)", levelHeight_Sub_L_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", levelHeight_Add_L_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("R", xStart + 8 + 160, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("(-)", levelHeight_Sub_R_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);
    RenderText("(+)", levelHeight_Add_R_Btn.boundingBox.position.x + 4, yStart + 44 - getFontHeight() * 0.75 + yOffset1, color(255), TEXTH.LEFT, 0.75);

    fill(43);
    rect(xStart, yStart + 44 - (getFontHeight() * 0.75) + yOffset1 + 40, foreground.size.x, 5);

    //
    RenderText("Clear Level", xStart + 4, yStart - getFontHeight() * 0.25 + yOffset1 * 2, color(255), TEXTH.LEFT, 0.75);

    RenderText("YES", xStart + 8, yStart + 44 - getFontHeight() * 0.75 + yOffset1 * 2, color(255), TEXTH.LEFT, 0.75);

    //
    unbindViewport();
  }
}
