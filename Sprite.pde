//
class Sprite
{
  public PImage image;
  public boolean flipHorizontally;
  public boolean flipVertically;

  Sprite(Texture tex, boolean flipH, boolean flipV)
  {
    if (tex == null)
    {
      println("Error loading null texture for sprite");
      image = null;
    } else
      image = tex.image;

    flipHorizontally = flipH;
    flipVertically = flipV;
  }

}
