
static class Editor
{
  public static boolean enabled = false;
  public static boolean preventLevelCompletion = false;

  public static BlockType BlockDraw = BlockType.WALL;
  public static int BlockDrawIndex = 0;
  public static ArrayList<BlockType> BlockDrawList = new ArrayList<BlockType>() {
    {
      add(BlockType.WALL);
      add(BlockType.FLOOR);
      add(BlockType.TARGET);
      add(BlockType.BLOCK);
      add(BlockType.BLOCK_H);
      add(BlockType.BLOCK_V);
      add(BlockType.PLAYER);
      add(BlockType.SIGN);
      add(BlockType.CRATE);
      add(BlockType.SNOW);
      add(BlockType.PLANT);
      add(BlockType.FENCE);
      add(BlockType.ARROW_UP);
      add(BlockType.ARROW_DOWN);
      add(BlockType.ARROW_LEFT);
      add(BlockType.ARROW_RIGHT);
    }
  };
  public static ArrayList<String> BlockDrawSpriteList = new ArrayList<String>() {
    {
      add("wall_A_alone");
      add("floor_1");
      add("target_1");
      add("block_1");
      add("block_h_1");
      add("block_v_1");
      add("guy_1_right");
      add("sign_1");
      add("crate_1");
      add("snow_1");
      add("plant_1");
      add("fence_1");
      add("arrow_up");
      add("arrow_down");
      add("arrow_left");
      add("arrow_right");
    }
  };

  public static void SelectBlock(int x, int y, GameMap gameMap)
  {
    // Get Entity
    if (gameMap.entityLayer.nodes[x][y].type != BlockType.NOTHING)
    {
      BlockType target = gameMap.entityLayer.nodes[x][y].type;
      for (int i = 0; i < BlockDrawList.size(); i++)
      {
        if (BlockDrawList.get(i) == target)
        {
          BlockDrawIndex = i;
          BlockDraw = BlockDrawList.get(i);
        }
      }
    }
    // Get BG if no entity available
    else if (gameMap.bgLayer.nodes[x][y].type != BlockType.NOTHING)
    {
      BlockType target = gameMap.bgLayer.nodes[x][y].type;
      for (int i = 0; i < BlockDrawList.size(); i++)
      {
        if (BlockDrawList.get(i) == target)
        {
          BlockDrawIndex = i;
          BlockDraw = BlockDrawList.get(i);
        }
      }
    }
  }
  public static void DrawBlock(int x, int y, GameMap gameMap)
  {
    // Remove Undos
    gameMap.ClearUndos();

    // Entity Layer
    if (getLayerType(Editor.BlockDraw))
    {
      gameMap.entityLayer.SetBlock(x, y, Editor.BlockDraw);
      gameMap.bgLayer.SetBlock(x, y, BlockType.NOTHING);
    }
    // BG Layer
    else
    {
      gameMap.entityLayer.SetBlock(x, y, BlockType.NOTHING);
      gameMap.bgLayer.SetBlock(x, y, Editor.BlockDraw);
    }

    // Considerations
    if (Editor.BlockDraw == BlockType.TARGET)
      gameMap.RecalculateTargetCount();
  }
  public static void EraseBlock(int x, int y, GameMap gameMap)
  {
    // Remove Undos
    gameMap.ClearUndos();

    boolean MapChanged = false;
    // Considerations before delete
    if (gameMap.bgLayer.nodes[x][y].type == BlockType.TARGET)
      MapChanged = true;

    gameMap.bgLayer.SetBlock(x, y, BlockType.NOTHING);
    gameMap.entityLayer.SetBlock(x, y, BlockType.NOTHING);

    if (MapChanged)
      gameMap.RecalculateTargetCount();
  }

  public static void SetBlockDrawIndex(int index)
  {
    BlockDrawIndex = constrain(index, 0, BlockDrawList.size() - 1);

    BlockDraw = BlockDrawList.get(BlockDrawIndex);
  }
  public static void NextBlockDrawIndex(int increase)
  {
    BlockDrawIndex += increase;

    if (BlockDrawIndex >= BlockDrawList.size())
      BlockDrawIndex = 0;
    else if (BlockDrawIndex < 0)
      BlockDrawIndex = BlockDrawList.size() - 1;

    BlockDraw = BlockDrawList.get(BlockDrawIndex);
  }
}
