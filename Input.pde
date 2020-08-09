//
static class Input
{
  // Data
  private static HashMap<Character, Boolean> KeyPressLetter = new HashMap<Character, Boolean>();
  private static HashMap<Character, Boolean> KeyPressLetter_Down = new HashMap<Character, Boolean>();

  private static HashMap<Integer, Boolean> KeyPressSpecial = new HashMap<Integer, Boolean>();
  private static HashMap<Integer, Boolean> KeyPressSpecial_Down = new HashMap<Integer, Boolean>();

  private static HashMap<Integer, Boolean> MousePress = new HashMap<Integer, Boolean>();

  private static float ScrollDelta = 0.0;

  public static boolean GetKey(char c)
  {
    if (KeyPressLetter.get(c) == null)
      KeyPressLetter.put(c, false);

    return KeyPressLetter.get(c);
  }
  //UP, DOWN, LEFT, RIGHT) as well as ALT, CONTROL, and SHIFT.
  public static boolean GetKey(int input)
  {
    if (KeyPressSpecial.get(input) == null)
      KeyPressSpecial.put(input, false);

    return KeyPressSpecial.get(input);
  }
  public static boolean GetKeyDown(char c)
  {
    if (KeyPressLetter_Down.get(c) == null)
      KeyPressLetter_Down.put(c, false);

    return KeyPressLetter_Down.get(c);
  }
  public static boolean GetKeyDown(int input)
  {
    if (KeyPressSpecial_Down.get(input) == null)
      KeyPressSpecial_Down.put(input, false);

    return KeyPressSpecial_Down.get(input);
  }
  // LEFT, RIGHT, CENTER
  public static boolean GetMouseButton(int input)
  {
    if (MousePress.get(input) == null)
      MousePress.put(input, false);

    return MousePress.get(input);
  }
  
  public static float GetScrollDelta()
  {
    return ScrollDelta;
  }

  public static void EndUpdate()
  {
    for (Map.Entry mapElement : KeyPressLetter_Down.entrySet())
      mapElement.setValue(false);
    for (Map.Entry mapElement : KeyPressSpecial_Down.entrySet())
      mapElement.setValue(false);

    Input.ScrollDelta = 0.0;
  }
}


//
void keyPressed()
{
  Input.KeyPressLetter.put(key, true);
  Input.KeyPressLetter_Down.put(key, true);
  Input.KeyPressSpecial.put(keyCode, true);
  Input.KeyPressSpecial_Down.put(keyCode, true);
}
//
void keyReleased()
{
  Input.KeyPressLetter.put(key, false);
  Input.KeyPressLetter_Down.put(key, false);
  Input.KeyPressSpecial.put(keyCode, false);
  Input.KeyPressSpecial_Down.put(keyCode, false);
}
//
void mousePressed()
{
  Input.MousePress.put(mouseButton, true);
}
//
void mouseReleased()
{
  Input.MousePress.put(mouseButton, false);
}
//
void mouseWheel(MouseEvent event) {
  Input.ScrollDelta = event.getCount();
}
