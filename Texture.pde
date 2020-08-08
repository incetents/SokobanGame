//
class Texture
{
  public PImage image;
  
  public Texture(String path)
  {
    image = loadImage(path);
    if(image == null)
      println("MISSING PATH: " + path);
  }
}
