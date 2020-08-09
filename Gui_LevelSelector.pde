
class Gui_LevelSelector extends GuiWindow
{
  // Data
  private ArrayList<File> levelFiles = new ArrayList<File>();
  private ArrayList<Button> levelButtons = new ArrayList<Button>();

  private float lowerGuiHeight = 20;
  private Button export_btn = new Button(ButtonType.SQUARE);

  private Viewport viewport_selectionArea = new Viewport();
  private Viewport viewport_miniBar = new Viewport();

  //
  public Gui_LevelSelector(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    super(_title, _position, _size, _minSize);

    refreshLevelSelection();
  }

  public void refreshLevelSelection()
  {
    levelFiles.clear();
    levelButtons.clear();

    //levelPaths
    //println(dataPath("Levels/"));
    File[] files = listFiles(dataPath("Levels/"));
    for (int i = 0; i < files.length; i++) {
      File f = files[i];   
      if (f.isFile())
      {
        levelFiles.add(f);
        levelButtons.add(new Button(ButtonType.SQUARE));
      }
      //f.isDirectory()
      //f.length()
    }
  }

  public void update()
  {
    super.update();

    export_btn.update();

    export_btn.setPosition(foreground.position.x, foreground.position.y + foreground.size.y - lowerGuiHeight);
    export_btn.boundingBox.size = new PVector(lowerGuiHeight, lowerGuiHeight);

    viewport_selectionArea.setCenter(
      foreground.position.x + foreground.size.x / 2.0, 
      foreground.position.y + foreground.size.y / 2.0 - lowerGuiHeight / 2.0
      );
    viewport_selectionArea.setSize(
      foreground.size.x, 
      foreground.size.y - lowerGuiHeight
      );

    viewport_miniBar.setCenter(
      foreground.position.x + foreground.size.x / 2.0, 
      foreground.position.y + foreground.size.y - lowerGuiHeight / 2.0
      );
    viewport_miniBar.setSize(
      foreground.size.x, 
      lowerGuiHeight
      );

    // MiniBar
    if (export_btn.isReleased())
    {
      selectOutput("Export Level", "ExportLevel", new File(dataPath("Levels")));
    }

    // Selection Area
    boolean MouseCanTouchButtons = viewport_selectionArea.isMouseInside();
    for (int i = 0; i < levelFiles.size(); i++)
    {
      float x = foreground.position.x;
      float y = foreground.position.y + i * 24;
      float w = foreground.size.x - 24;
      float h = 20;

      Button btn = levelButtons.get(i);

      btn.update();
      btn.boundingBox.position.x = x;
      btn.boundingBox.position.y = y;
      btn.boundingBox.size.x = w;
      btn.boundingBox.size.y = h;

      if (MouseCanTouchButtons && btn.isReleasedOnButton())
      {
        String path = levelFiles.get(i).getPath();
        if (fileExists(path))
          ImportLevel(path);          
        else
          refreshLevelSelection();
          
        return;
      }
    }
  }

  public void draw()
  {
    super.draw();

    //
    viewport_selectionArea.bind();

    for (int i = 0; i < levelFiles.size(); i++)
    {
      float x = foreground.position.x;
      float y = foreground.position.y + i * 24;

      Button btn = levelButtons.get(i);
      if (btn.isPressed())
        btn.draw(124);
      else if (btn.isHovered())
        btn.draw(0);
      else
        btn.draw(84);

      RenderText(levelFiles.get(i).getName(), x + 4, y - getFontHeight() / 2.0, color(0, 255, 255), TEXTH.LEFT, 0.5);
    }

    //
    viewport_miniBar.bind();

    if (export_btn.isHovered() && !mousePressed)
      export_btn.draw(color(255));
    else
      export_btn.draw(color(150));

    RenderText("EXPORT CUREENT LEVEL", export_btn.getPosition().x + 24, export_btn.getPosition().y - getFontHeight() / 2.0, color(255), TEXTH.LEFT, 0.5);

    //
    unbindViewport();
  }
}
