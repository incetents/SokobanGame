

//PShape test;

//test = createShape();
//test.beginShape(TRIANGLES);
//test.noStroke();

//test.vertex(30, 20);
//test.vertex(85, 20);
//test.vertex(85, 75);
//test.vertex(30, 75);

//test.endShape();
// shape(test) 

public enum Direction
{
  NONE, 
    UP, 
    DOWN, 
    LEFT, 
    RIGHT
}

public final PVector[] DirectionOffsetList =
  {
  new PVector(0, 0), 
  new PVector(0, -1), 
  new PVector(0, 1), 
  new PVector(-1, 0), 
  new PVector(1, 0)
};
public PVector GetDirectionOffset(Direction direction)
{
  switch(direction)
  {
  default:
    return DirectionOffsetList[0];
  case UP:
    return DirectionOffsetList[1];
  case DOWN:
    return DirectionOffsetList[2];
  case LEFT:
    return DirectionOffsetList[3];
  case RIGHT:
    return DirectionOffsetList[4];
  }
}

Direction flipDirection(Direction direction)
{
  switch(direction)
  {
  default:
  case UP:
    return Direction.DOWN;
  case DOWN:
    return Direction.UP;
  case LEFT:
    return Direction.RIGHT;
  case RIGHT:
    return Direction.LEFT;
  }
}

ArrayList<File> GetAllLevelFiles()
{
  //levelPaths
  //println(dataPath("Levels/"));
  ArrayList<File> levelFiles = new ArrayList<File>();
  File[] files = listFiles(dataPath("Levels/"));
  for (int i = 0; i < files.length; i++) {
    File f = files[i];   
    if (f.isFile() && validateExtension(f.getName(), ".level"))
    {
      levelFiles.add(f);
    }
    //f.isDirectory()
    //f.length()
  }
  return levelFiles;
}

boolean fileExists(String path)
{
  File file = new File(dataPath(path));
  return file.exists();
}

File changeExtension(File f, String newExtension) {
  int i = f.getName().lastIndexOf('.');
  if (i == -1)
    return new File(f.getAbsolutePath() + newExtension);

  String name = f.getName().substring(0, i);
  return new File(f.getParent() + "/" + name + newExtension);
}
String getFilenameWithoutExtension(String name)
{
  int i = name.lastIndexOf('.');
  if (i == -1)
    return name;

  return name.substring(0, i);
}
boolean validateExtension(String name, String extension)
{
  int i = name.lastIndexOf('.');
  if (i == -1)
    return false;

  return name.substring(i, name.length()).equals(extension);
}

PVector GetNodeCenterFromIndex(int x, int y)
{
  return new PVector(
    (x * BlockSize) + camera.getX() + BlockSize/2.0, 
    (y * BlockSize) + camera.getY() + BlockSize/2.0
    );
}
PVector GetNodePositionFromIndex(int x, int y)
{
  return new PVector(
    (x * BlockSize) + camera.getX(), 
    (y * BlockSize) + camera.getY()
    );
}

float sign (PVector p1, PVector p2, PVector p3)
{
  return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

boolean PointInTriangle (PVector pt, PVector v1, PVector v2, PVector v3)
{
  float d1, d2, d3;
  boolean has_neg, has_pos;

  d1 = sign(pt, v1, v2);
  d2 = sign(pt, v2, v3);
  d3 = sign(pt, v3, v1);

  has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

  return !(has_neg && has_pos);
}
