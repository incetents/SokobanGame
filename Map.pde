
String ErrorLevel =
  "XXXXXXXXXXXXXXXXXXXX\n"+
  "X000000000000000000X\n"+
  "X000000000000000000X\n"+
  "X000000000000000000X\n"+
  "X000000000P00000000X\n"+
  "X000000000000000000X\n"+
  "X000000000000000000X\n"+
  "X000000000000000000X\n"+
  "XXXXXXXXXXXXXXXXXXXX\n";

static HashMap<Character, BlockType> levelReader = new HashMap<Character, BlockType>()
{
  {
    put('0', BlockType.NOTHING);
    put('X', BlockType.WALL);
    put('P', BlockType.PLAYER);
    put('B', BlockType.BLOCK);
    put('H', BlockType.BLOCK_H);
    put('V', BlockType.BLOCK_V);
    put('F', BlockType.FLOOR);
    put('T', BlockType.TARGET);
    put('S', BlockType.SIGN);
    put('C', BlockType.CRATE);
    put('Z', BlockType.SNOW);
    put('A', BlockType.PLANT);
    put('a', BlockType.FENCE);
    put('1', BlockType.ARROW_UP);
    put('2', BlockType.ARROW_DOWN);
    put('3', BlockType.ARROW_LEFT);
    put('4', BlockType.ARROW_RIGHT);
  }
};
static HashMap<BlockType, Boolean> layerType = new HashMap<BlockType, Boolean>()
{
  {
    put(BlockType.PLAYER, true);
    put(BlockType.BLOCK, true);
    put(BlockType.BLOCK_H, true);
    put(BlockType.BLOCK_V, true);
  }
};
public static Boolean getLayerType(BlockType type)
{
  if (layerType.get(type) == null)
    return false;

  return true;
}

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
  if (levelWriter.get(type) == null)
  {
    println("DUPLICATE CHAR VALUE FOR SAVING FOR TYPE: " + type);
    return '0';
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

  public void SubWidth(boolean isRight)
  {
    // Min Size
    if (m_width == 0)
      return;

    Node[][] newNodes = new Node[m_width - 1][m_height];

    // Copy old nodes
    for (int x = 0; x < m_width - 1; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        if (isRight)
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x][y]);
        } else
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x+1][y]);
        }
      }
    }

    // Flags
    nodes = newNodes;
    m_width--;
  }
  public void SubHeight(boolean isUp)
  {
    // Min Size is 2x2
    if (m_height == 0)
      return;

    Node[][] newNodes = new Node[m_width][m_height - 1];

    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height - 1; y++)
      {
        if (isUp)
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x][y]);
        } else
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x][y + 1]);
        }
      }
    }

    // Flags
    nodes = newNodes;
    m_height--;
  }

  public void AddWidth(boolean isRight)
  {
    Node[][] newNodes = new Node[m_width + 1][m_height];
    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        if (isRight)
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x][y]);
        } else
        {
          newNodes[x+1][y] = new Node();
          newNodes[x+1][y].copy(nodes[x][y]);
        }
      }
    }
    // Create new column
    for (int y = 0; y < m_height; y++)
    {
      if (isRight)
        newNodes[m_width][y] = new Node();
      else
        newNodes[0][y] = new Node();
    }

    // Flags
    nodes = newNodes;
    m_width++;
  }
  public void AddHeight(boolean isUp)
  {
    Node[][] newNodes = new Node[m_width][m_height + 1];
    // Copy old nodes
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        if (isUp)
        {
          newNodes[x][y] = new Node();
          newNodes[x][y].copy(nodes[x][y]);
        } else
        {
          newNodes[x][y+1] = new Node();
          newNodes[x][y+1].copy(nodes[x][y]);
        }
      }
    }
    // Create new row
    for (int x = 0; x < m_width; x++)
    {
      if (isUp)
        newNodes[x][m_height] = new Node();
      else
        newNodes[x][0] = new Node();
    }

    // Flags
    nodes = newNodes;
    m_height++;
  }

  public void clear()
  {
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        nodes[x][y].clear();
      }
    }
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
  public String levelMessage;
  public float readingMessageT = 0;
  public boolean readingMessage = false;
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

  public void ClearUndos()
  {
    if (UndoEvents.size() > 0)
      UndoEvents = new ArrayList<GameUndoEvent>();
  }

  public void RecalculateTargetCount()
  {
    targetsFilled = 0;
    targetCount = 0;
    for (int x = 0; x < m_width; x++)
    {
      for (int y = 0; y < m_height; y++)
      {
        BlockType t = bgLayer.nodes[x][y].type;
        if (t == BlockType.TARGET)
        {
          targetCount++;
          if (gameMap.entityLayer.nodes[x][y].targetPiece)
          {
            targetsFilled++;
          }
        }
      }
    }
  }

  public boolean SubWidth(boolean isRight)
  {
    if (m_width == 0)
      return false;

    m_width--;
    bgLayer.SubWidth(isRight);
    entityLayer.SubWidth(isRight);

    return true;
  }
  public boolean AddWidth(boolean isRight)
  {
    m_width++;
    bgLayer.AddWidth(isRight);
    entityLayer.AddWidth(isRight);

    return true;
  }

  public boolean SubHeight(boolean isUp)
  {
    if (m_height == 0)
      return false;

    m_height--;
    bgLayer.SubHeight(isUp);
    entityLayer.SubHeight(isUp);

    return true;
  }
  public boolean AddHeight(boolean isUp)
  {
    m_height++;
    bgLayer.AddHeight(isUp);
    entityLayer.AddHeight(isUp);

    return true;
  }

  public void clear()
  {
    bgLayer.clear();
    entityLayer.clear();
  }

  public void update()
  {
    if (readingMessage)
      readingMessageT += deltaTime;
    else
      readingMessageT = 0;
  }

  public GameMap(String _levelPath, String _levelMap, String _levelMessage)
  {
    levelName = getFilenameWithoutExtension(new File(_levelPath).getName());
    levelPath = _levelPath;
    levelMap = _levelMap;
    levelMessage = _levelMessage;//"Hey KokSucker, you see that block over there,\nI'm gonna need you to push it!\n\n\n\n\nSincerely,\n  -DeezNuts";

    // Find first \n to find width
    int i = _levelMap.indexOf('\n');
    // Empty
    if (_levelMap.isEmpty())
    {
      m_width = 0;
      m_height = 0;
    }
    //
    else if (i == -1)
    {
      m_width = _levelMap.length();
      m_height = 1;
    }
    //
    else
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
        // Check if entity layer
        if (getLayerType(t))
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
      if (bgNode.type == BlockType.TARGET)
      {
        if (m.node.targetPiece)
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
    }

    // Count all blocks on top of targets
    RecalculateTargetCount();

    if (AddToUndo)
    {
      // Add To Undo Event
      UndoEvents.add(new GameUndoEvent(movingNodes));
    }
  }

  public boolean IsReadingMessage()
  {
    return readingMessage;
  }

  public void SetReadingMessage(boolean state)
  {
    if (state)
    {
      for (int x = 0; x < gameMap.m_width; x++)
      {
        for (int y = 0; y < gameMap.m_height; y++)
        {
          if (entityLayer.nodes[x][y].type == BlockType.PLAYER)
          {
            if (bgLayer.nodes[x][y].type == BlockType.SIGN)
            {
              readingMessage = true;
            }
          }
        }
      }
    } else
      readingMessage = false;
  }

  //
}
