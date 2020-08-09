
enum TEXTH
{
  LEFT, 
    CENTER, 
    RIGHT
}

float getFontHeight()
{
  if (CurrentFont != null)
    return CurrentFont.fontHeight;

  return 0;
}

void RenderTextBG(String msg, float x, float y, float padding, color c, float size)
{
  textSize(getFontHeight() * size);
  float msg_width = textWidth(msg);

  fill(c);
  rect(x - msg_width/2.0 - padding/2.0, y + 5 - padding/2.0, msg_width + padding, 30 + padding);
}
void RenderText(String msg, float x, float y, color c, TEXTH h, float size)
{
  textSize(getFontHeight() * size); 
  float msg_width = textWidth(msg);

  fill(c);
  if (h == TEXTH.CENTER)
    text(msg, x - msg_width/2.0, y + 30);
  else if (h == TEXTH.LEFT)
    text(msg, x, y + 30);
  else
    text(msg, x - msg_width, y + 30);
}
