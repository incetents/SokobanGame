
class Gui_LevelSelector extends GuiWindow
{
  // Data
  private ArrayList<String> levelNames = new ArrayList<String>();
  //private String targetLevel = null;

  private ArrayList<Button> levelButtons = new ArrayList<Button>();

  //
  public Gui_LevelSelector(String _title, PVector _position, PVector _size, PVector _minSize)
  {
    super(_title, _position, _size, _minSize);

    //levelPaths
    //println(dataPath("Levels/"));
    File[] files = listFiles(dataPath("Levels/"));
    for (int i = 0; i < files.length; i++) {
      File f = files[i];   
      if (f.isFile())
      {
        levelNames.add(f.getName());
        levelButtons.add(new Button(ButtonType.SQUARE));
      }
      //f.isDirectory()
      //f.length()
    }
  }

  public void update()
  {
    super.update();

    for (int i = 0; i < levelNames.size(); i++)
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

      if (btn.isReleasedOnButton())
      {
        println(levelNames.get(i));
        close = true;
        return;
      }
    }
  }

  public void draw()
  {
    super.draw();

    for (int i = 0; i < levelNames.size(); i++)
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

      RenderText(levelNames.get(i), x + 4, y - getFontHeight() / 2.0, color(0, 255, 255), TEXTH.LEFT, 0.5);
    }
  }
}
