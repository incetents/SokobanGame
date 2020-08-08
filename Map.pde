
String levelLayout =
  "XXXX00XXXXXXXXXXXXXX"+
  "XFF0F0000X0X0000000X"+
  "XFFF0B000XXX000X000X"+
  "X0F0000X000000X0X00X"+
  "XFF000XXX00XX00X000X"+
  "XF0BB00X00000000BT0X"+
  "XFX0B00000000P0B0T0X"+
  "XFFF000000000000000X"+
  "XXXXXX0B0XXXXXXXXXXX";

HashMap<Character, BlockType> levelInterpreter = new HashMap<Character, BlockType>()
{
  {
    put('0', BlockType.NOTHING);
    put('X', BlockType.WALL);
    put('P', BlockType.PLAYER);
    put('B', BlockType.BLOCK);
    put('F', BlockType.FLOOR);
    put('T', BlockType.TARGET);
  }
};
public BlockType InterpretMapChar(char c)
{
  if (levelInterpreter.get(c) == null)
    levelInterpreter.put(c, BlockType.ERROR);

  return levelInterpreter.get(c);
}

class GameLayer
{
  public int m_width;
  public int m_height;
  public Node[][] nodes;

  public GameLayer(int w, int h)
  {
    m_width = w;
    m_height = h;
    nodes = new Node[w][h];

    for (int x = 0; x < m_width; x++)
      for (int y = 0; y < m_height; y++)
        nodes[x][y] = new Node();
  }
  public Node GetNode(int x, int y)
  {
    return nodes[x][y];
  }

  // Modifies block and updates all surrounding blocks
  public void SetBlock(int x, int y, BlockType type)
  {
    if (IsInsideBoard(x, y))
      nodes[x][y].SetType(type);

    for (int _x = x - 1; _x <= x + 1; _x++)
    {
      for (int _y = y - 1; _y <= y + 1; _y++)
      {
        if (IsInsideBoard(_x, _y))
          nodes[_x][_y].UpdateSprite(_x, _y);
      }
    }
  }

  public boolean IsInsideBoard(float x, float y)
  {
    return IsInsideBoard(int(x), int(y));
  }
  public boolean IsInsideBoard(int x, int y)
  {
    return x >= 0 && x < m_width && y >= 0 && y < m_height;
  }
}

class GameUndoEvent
{
  public ArrayList<MovingNode> nodes;

  public GameUndoEvent(ArrayList<MovingNode> _nodes)
  {
    nodes = _nodes;
  }
}

class GameMap
{
  public int m_width;
  public int m_height;
  public GameLayer bgLayer;
  public GameLayer entityLayer;
  private int targetCount = 0;
  public int targetsFilled = 0;

  private ArrayList<GameUndoEvent> UndoEvents = new ArrayList<GameUndoEvent>();

  public boolean IsInsideBoard(float x, float y)
  {
    return IsInsideBoard(int(x), int(y));
  }
  public boolean IsInsideBoard(int x, int y)
  {
    return x >= 0 && x < m_width && y >= 0 && y < m_height;
  }

  public GameMap(String levelMap, int w)
  {
    int h = levelMap.length() / w;
    m_width = w;
    m_height = h;
    bgLayer = new GameLayer(w, h);
    entityLayer = new GameLayer(w, h);

    // Setup scene
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        //int flipY = (m_height - y) - 1;

        // Interpret map for type
        int stringIndex = x + y * m_width;
        char c = levelMap.charAt(stringIndex);
        BlockType t = InterpretMapChar(c);
        if (t == BlockType.PLAYER || t == BlockType.BLOCK)
          entityLayer.nodes[x][y].SetType(t);
        else
          bgLayer.nodes[x][y].SetType(t);

        if (t == BlockType.TARGET)
          targetCount++;
      }
    }
  }

  public void UpdateAllSprites()
  {
    // Second Pass now set sprites too
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        bgLayer.nodes[x][y].UpdateSprite(x, y);
        entityLayer.nodes[x][y].UpdateSprite(x, y);
      }
    }
  }

  public void MovementTick(boolean AddToUndo)
  {
    //
    TickCounter += 1;

    // Copy all moving Nodes
    ArrayList<MovingNode> movingNodes = new ArrayList<MovingNode>();
    // Copy and delete
    for (int x = 0; x < gameMap.m_width; x++)
    {
      for (int y = 0; y < gameMap.m_height; y++)
      {
        // check for movement
        if (gameMap.entityLayer.nodes[x][y].moveDirection != Direction.NONE)
        {
          // Store Data
          movingNodes.add(new MovingNode(gameMap.entityLayer.nodes[x][y], new PVector(x, y)));
          // Remove existing data
          gameMap.entityLayer.nodes[x][y].clear();
        }
      }
    }
    // Add Moved Data
    for (int i = 0; i < movingNodes.size(); i++)
    {
      MovingNode m = movingNodes.get(i);
      Node entityNode = gameMap.entityLayer.nodes[int(m.position.x)][int(m.position.y)];
      Node bgNode = gameMap.bgLayer.nodes[int(m.position.x)][int(m.position.y)];

      entityNode.copy(m.node);
      entityNode.moveDirection = Direction.NONE;
      entityNode.UpdateSprite(int(m.position.x), int(m.position.y));

      // Transform effect
      if (m.node.type == BlockType.BLOCK && bgNode.type == BlockType.TARGET)
      {
        PVector pos = GetNodeCenterFromIndex(int(m.position.x), int(m.position.y));
        EmitterController.add(new Emitter(
          pos.x, pos.y, // X, Y
          0.45, 6, // Lifetime, Count
          color(255), color(41, 132, 167), // Color (start/end)
          30, 0, // Size (start/end)
          3, 6, 0.2, // SpeedMin, SpeedMax, Drag
          new PVector(0, 1), 360 // Direction, AngleFuzz
          ));
      }
    }

    // Count all blocks on top of targets
    targetsFilled = 0;
    for (int x = 0; x < gameMap.m_width; x++)
    {
      for (int y = 0; y < gameMap.m_height; y++)
      {
        if (gameMap.bgLayer.nodes[x][y].type == BlockType.TARGET)
        {
          if (gameMap.entityLayer.nodes[x][y].type == BlockType.BLOCK)
          {
            targetsFilled++;
          }
        }
      }
    }

    if (AddToUndo)
    {
      // Add To Undo Event
      UndoEvents.add(new GameUndoEvent(movingNodes));
    }
  }
}