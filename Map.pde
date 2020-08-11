
final int MinimumMaxSize = 2;

String ErrorLevel =
  "XXXX00XXXXXXXXXXXXXX\n"+
  "XFF0F0000X0X0000000X\n"+
  "XFFF0B000XXX000X000X\n"+
  "X0F0000X000000X0X00X\n"+
  "XFF000XXX00XX00X000X\n"+
  "XF0BB00X00000000BT0X\n"+
  "XFX0B00000000P0B0T0X\n"+
  "XFFF000000000000000X\n"+
  "XXXXXX0B0XXXXXXXXXXX\n";

HashMap<Character, BlockType> levelReader = new HashMap<Character, BlockType>()
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
HashMap<BlockType, Character> levelWriter = new HashMap<BlockType, Character>();
public char WriteMapChar(BlockType type)
{
  // Effectively reversed from levelReader
  if (levelWriter.get(type) == null)
  {
    for (Map.Entry mapElement : levelReader.entrySet())
    {
      BlockType t = (BlockType)mapElement.getValue();
      if (t == type)
      {
        levelWriter.put(type, (char)mapElement.getKey());
      }
    }
  }
  return levelWriter.get(type);
}
public BlockType ReadMapChar(char c)
{
  if (levelReader.get(c) == null)
    levelReader.put(c, BlockType.ERROR);

  return levelReader.get(c);
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

  public void SubWidth()
  {
    // Min Size is 2x2
    if (m_width == 2)
      return;

    Node[][] newNodes = new Node[m_width - 1][m_height];

    // Copy old nodes
    for (int x = 0; x < m_width - 1; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        newNodes[x][y] = new Node();
        newNodes[x][y].copy(nodes[x][y]);
      }
    }

    // Flags
    nodes = newNodes;
    m_width--;
  }
  public void SubHeight()
  {
    // Min Size is 2x2
    if (m_height == 2)
      return;

    Node[][] newNodes = new Node[m_width][m_height - 1];

    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height - 1; y++)
      {
        newNodes[x][y] = new Node();
        newNodes[x][y].copy(nodes[x][y]);
      }
    }

    // Flags
    nodes = newNodes;
    m_height--;
  }

  public void AddWidth()
  {
    Node[][] newNodes = new Node[m_width + 1][m_height];
    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        newNodes[x][y] = new Node();
        newNodes[x][y].copy(nodes[x][y]);
      }
    }
    // Create new column
    for (int y = 0; y < m_height; y++)
    {
      newNodes[m_width][y] = new Node();
    }

    // Flags
    nodes = newNodes;
    m_width++;
  }
  public void AddHeight()
  {
    Node[][] newNodes = new Node[m_width][m_height + 1];
    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        newNodes[x][y] = new Node();
        newNodes[x][y].copy(nodes[x][y]);
      }
    }
    // Create new row
    for (int x = 0; x < m_width; x++)
    {
      newNodes[x][m_height] = new Node();
    }

    // Flags
    nodes = newNodes;
    m_height++;
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
  public String levelName;
  public String levelPath;
  public String levelMap;
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

  public void RecalculateTargetCount()
  {
    targetCount = 0;
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        BlockType t = bgLayer.nodes[x][y].type;
        if (t == BlockType.TARGET)
          targetCount++;
      }
    }
  }

  public boolean SubWidth()
  {
    if (m_width == 2)
      return false;

    m_width--;
    bgLayer.SubWidth();
    entityLayer.SubWidth();

    return true;
  }
  public boolean AddWidth()
  {
    m_width++;
    bgLayer.AddWidth();
    entityLayer.AddWidth();

    return true;
  }

  public boolean SubHeight()
  {
    if (m_height == 2)
      return false;

    m_height--;
    bgLayer.SubHeight();
    entityLayer.SubHeight();

    return true;
  }
  public boolean AddHeight()
  {
    m_height++;
    bgLayer.AddHeight();
    entityLayer.AddHeight();

    return true;
  }

  public GameMap(String _levelPath, String _levelMap)
  {
    levelName = getFilenameWithoutExtension(new File(_levelPath).getName());
    levelPath = _levelPath;
    levelMap = _levelMap;

    // Find first \n to find width
    int i = _levelMap.indexOf('\n');
    if (i == -1)
    {
      m_width = _levelMap.length();
      m_height = 1;
    } else
    {
      m_width = i;
      m_height = levelMap.length() / (i + 1);
    }

    bgLayer = new GameLayer(m_width, m_height);
    entityLayer = new GameLayer(m_width, m_height);

    int stringIndex = 0;

    // Setup scene
    for (int y = 0; y < m_height; y++)
    {
      for (int x = 0; x < m_width; x++)
      {
        // Skip characters that are not important
        while (stringIndex < levelMap.length() && levelMap.charAt(stringIndex) == '\n')
          stringIndex++;
        if (stringIndex >= levelMap.length())
          break;

        // Interpret map for type
        char c = levelMap.charAt(stringIndex);
        stringIndex++;

        BlockType t = ReadMapChar(c);
        if (t == BlockType.PLAYER || t == BlockType.BLOCK)
          entityLayer.nodes[x][y].SetType(t);
        else
          bgLayer.nodes[x][y].SetType(t);

        if (t == BlockType.TARGET)
          targetCount++;
      }
    }

    // Size of block based on screen size
    AdjustBlockSize(this);
    // Move camera to center
    camera.setPositionToCenterOfMap(this);
    //
    EmitterController.clear();
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
