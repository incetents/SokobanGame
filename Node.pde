//
public enum BlockType
{
  NOTHING, 
    ERROR, 
    WALL, 
    PLAYER, 
    BLOCK, 
    BLOCK_H, 
    BLOCK_V, 
    FLOOR, 
    TARGET, 
    SIGN
}
//
class MovingNode
{
  public Node node = new Node();
  public PVector position;

  public MovingNode(Node _node, PVector _position)
  {
    node.copy(_node);
    PVector offset =  GetDirectionOffset(_node.moveDirection);
    position = _position.add(offset);
  }
}
//
class Node
{
  public BlockType type = BlockType.NOTHING;
  public Direction moveDirection = Direction.NONE;
  public Sprite sprite = null;
  public Sprite[] spriteCorners = { null, null, null, null };
  public int flag = 0;
  public boolean multiSprite = false;
  public boolean solid = false;
  public boolean pushable_h = false;
  public boolean pushable_v = false;
  public boolean targetPiece = false;

  public void copy(Node other)
  {
    this.type = other.type;
    this.moveDirection = other.moveDirection;
    this.sprite = other.sprite;
    this.flag = other.flag;
    for (int i = 0; i < 4; i++)
      this.spriteCorners[i] = other.spriteCorners[i];
    this.solid = other.solid;
    this.pushable_h = other.pushable_h;
    this.pushable_v = other.pushable_v;
    this.targetPiece = other.targetPiece;
  }
  public void clear()
  {
    this.type = BlockType.NOTHING;
    this.moveDirection = Direction.NONE;
    this.sprite = null;
    this.flag = 0;
    for (int i = 0; i < 4; i++)
      this.spriteCorners[i] = null;
    this.solid = false;
    this.pushable_h = false;
    this.pushable_v = false;
    this.targetPiece = false;
  }

  public void SetType(BlockType type)
  {
    clear();
    this.type = type;

    switch(type)
    {
    default:
      break;
    case WALL:
      this.solid = true;
      break;
    case BLOCK_H:
      this.pushable_h = true;
      this.solid = true;
      this.targetPiece = true;
      break;
    case BLOCK_V:
      this.pushable_v = true;
      this.solid = true;
      this.targetPiece = true;
      break;
    case PLAYER:
      this.pushable_h = true;
      this.pushable_v = true;
      this.solid = true;
      break;
    case BLOCK:
      this.pushable_h = true;
      this.pushable_v = true;
      this.solid = true;
      this.targetPiece = true;
      break;
    }
  }

  public void draw(int x, int y, GameLayer layer)
  {
    // Movement effect
    PVector moveVector = GetDirectionOffset(layer.nodes[x][y].moveDirection);
    float animMoveX = (moveVector.x * BlockSize * animationTime);
    float animMoveY = (moveVector.y * BlockSize * animationTime);

    // Multi Sprite
    if (layer.nodes[x][y].multiSprite)
    {
      // Position
      float PositionX = (x * BlockSize + BlockSizeHalf + animMoveX);
      float PositionY = ((y * BlockSize) + BlockSizeHalf + animMoveY);

      if (layer.nodes[x][y].spriteCorners[0].image != null)
      {
        image(layer.nodes[x][y].spriteCorners[0].image, 
          PositionX - BlockSizeQuarter, PositionY - BlockSizeQuarter, 
          BlockSizeHalf, BlockSizeHalf);
      }
      if (layer.nodes[x][y].spriteCorners[1].image != null)
      {
        image(layer.nodes[x][y].spriteCorners[1].image, 
          PositionX + BlockSizeQuarter, PositionY - BlockSizeQuarter, 
          BlockSizeHalf, BlockSizeHalf);
      }
      if (layer.nodes[x][y].spriteCorners[2].image != null)
      {
        image(layer.nodes[x][y].spriteCorners[2].image, 
          PositionX - BlockSizeQuarter, PositionY + BlockSizeQuarter, 
          BlockSizeHalf, BlockSizeHalf);
      }
      if (layer.nodes[x][y].spriteCorners[3].image != null)
      {
        image(layer.nodes[x][y].spriteCorners[3].image, 
          PositionX + BlockSizeQuarter, PositionY + BlockSizeQuarter, 
          BlockSizeHalf, BlockSizeHalf);
      }
    }
    // Sprite
    else if (layer.nodes[x][y].sprite != null)
    {
      // Scale
      int scaleX = layer.nodes[x][y].sprite.flipHorizontally ? -1 : 1;
      int scaleY = layer.nodes[x][y].sprite.flipVertically ? -1 : 1;

      // Position
      float PositionX = scaleX * (x * BlockSize + BlockSizeHalf + animMoveX);
      float PositionY = scaleY * ((y * BlockSize) + BlockSizeHalf + animMoveY);

      push();
      scale(scaleX, scaleY);
      image(layer.nodes[x][y].sprite.image, 
        PositionX, PositionY, 
        BlockSize, BlockSize);
      pop();
    }
  }

  private Sprite GetSprite(int x, int y)
  {
    switch(type)
    {
    case WALL:
      {
        boolean topWall = gameMap.IsInsideBoard(x, y - 1) ? gameMap.bgLayer.GetNode(x, y - 1).type == BlockType.WALL : true;
        boolean botWall = gameMap.IsInsideBoard(x, y + 1) ? gameMap.bgLayer.GetNode(x, y + 1).type == BlockType.WALL : true;
        boolean leftWall = gameMap.IsInsideBoard(x - 1, y) ? gameMap.bgLayer.GetNode(x - 1, y).type == BlockType.WALL : true;
        boolean rightWall = gameMap.IsInsideBoard(x + 1, y) ? gameMap.bgLayer.GetNode(x + 1, y).type == BlockType.WALL : true;
        boolean topLeftWall = gameMap.IsInsideBoard(x - 1, y - 1) ? gameMap.bgLayer.GetNode(x - 1, y - 1).type == BlockType.WALL : true;
        boolean topRightWall = gameMap.IsInsideBoard(x + 1, y - 1) ? gameMap.bgLayer.GetNode(x + 1, y - 1).type == BlockType.WALL : true;
        boolean botLeftWall = gameMap.IsInsideBoard(x - 1, y + 1) ? gameMap.bgLayer.GetNode(x - 1, y + 1).type == BlockType.WALL : true;
        boolean botRightWall = gameMap.IsInsideBoard(x + 1, y + 1) ? gameMap.bgLayer.GetNode(x + 1, y + 1).type == BlockType.WALL : true;

        int adjacentCount = int(topWall) + int(botWall) + int(leftWall) + int(rightWall);
        int cornerCount = int(topLeftWall) + int(topRightWall) + int(botLeftWall) + int(botRightWall);
        int tileCount = int(topWall) + int(botWall) + int(leftWall) + int(rightWall) + int(topLeftWall) + int(topRightWall) + int(botLeftWall) + int(botRightWall);

        if (tileCount == 8)
          return null;

        switch(adjacentCount)
        {
        default:
        case 0:
          return SpriteMap.get("wall_A_alone");
        case 1:
          if (topWall)
            return SpriteMap.get("wall_A_single_bot");
          else if (botWall)
            return SpriteMap.get("wall_A_single_top");
          else if (leftWall)
            return SpriteMap.get("wall_A_single_right");
          else if (rightWall)
            return SpriteMap.get("wall_A_single_left");
          else
            return SpriteMap.get("wall_A_alone");
        case 2:
          if (topWall && leftWall)
            if (topLeftWall)
              return SpriteMap.get("wall_A_double_botright");
            else
              return SpriteMap.get("wall_A_double_botright_diag");

          else  if (topWall && rightWall)
            if (topRightWall)
              return SpriteMap.get("wall_A_double_botleft");
            else
              return SpriteMap.get("wall_A_double_botleft_diag");

          else  if (botWall && leftWall)
            if (botLeftWall)
              return SpriteMap.get("wall_A_double_topright");
            else
              return SpriteMap.get("wall_A_double_topright_diag");

          else  if (botWall && rightWall)
            if (botRightWall)
              return SpriteMap.get("wall_A_double_topleft");
            else
              return SpriteMap.get("wall_A_double_topleft_diag"); 

          else  if (topWall && botWall)
            return SpriteMap.get("wall_A_double_topbot");
          else  if (leftWall && rightWall)
            return SpriteMap.get("wall_A_double_leftright");
          else
            return SpriteMap.get("wall_A_alone");
        case 3:
          if (botWall && leftWall && rightWall)
          {
            if (botLeftWall && botRightWall)
              return SpriteMap.get("wall_A_triple_top");
            else if (!botLeftWall && botRightWall)
              return SpriteMap.get("wall_A_triple_top_L");
            else if (botLeftWall && !botRightWall)
              return SpriteMap.get("wall_A_triple_top_R");
            else
              return SpriteMap.get("wall_A_triple_top_LR");
          } else if (topWall && leftWall && rightWall)
          {
            if (topLeftWall && topRightWall)
              return SpriteMap.get("wall_A_triple_bot");
            else  if (!topLeftWall && topRightWall)
              return SpriteMap.get("wall_A_triple_bot_L");
            else  if (topLeftWall && !topRightWall)
              return SpriteMap.get("wall_A_triple_bot_R");
            else
              return SpriteMap.get("wall_A_triple_bot_LR");
          } else if (botWall && topWall && rightWall)
          {
            if (topRightWall && botRightWall)
              return SpriteMap.get("wall_A_triple_left");
            else if (!topRightWall && botRightWall)
              return SpriteMap.get("wall_A_triple_left_U");
            else if (topRightWall && !botRightWall)
              return SpriteMap.get("wall_A_triple_left_D");
            else
              return SpriteMap.get("wall_A_triple_left_UD");
          } else if (botWall && leftWall && topWall)
          {
            if (topLeftWall && botLeftWall)
              return SpriteMap.get("wall_A_triple_right");
            else if (!topLeftWall && botLeftWall)
              return SpriteMap.get("wall_A_triple_right_U");
            else if (topLeftWall && !botLeftWall)
              return SpriteMap.get("wall_A_triple_right_D");
            else
              return SpriteMap.get("wall_A_triple_right_UD");
          } else
            return null;
        case 4:
          // Check corner cases
          switch(cornerCount)
          {
          default:
          case 4:
            return SpriteMap.get("wall_A_Quad");
          case 3:
            if (!topRightWall)
              return SpriteMap.get("wall_A_corner_triple_topright");
            else  if (!topLeftWall)
              return SpriteMap.get("wall_A_corner_triple_topleft");
            else  if (!botRightWall)
              return SpriteMap.get("wall_A_corner_triple_botright");
            else  if (!botLeftWall)
              return SpriteMap.get("wall_A_corner_triple_botleft");
            else
              return SpriteMap.get("wall_A_alone"); 
          case 2:
            if (botRightWall && botLeftWall)
              return SpriteMap.get("wall_A_corner_double_up");
            else  if (topRightWall && topLeftWall)
              return SpriteMap.get("wall_A_corner_double_down");
            else  if (topRightWall && botRightWall)
              return SpriteMap.get("wall_A_corner_double_left");
            else  if (topLeftWall && botLeftWall)
              return SpriteMap.get("wall_A_corner_double_right");
            else  if (topLeftWall && botRightWall)
              return SpriteMap.get("wall_A_corner_double_forward");
            else  if (topRightWall && botLeftWall)
              return SpriteMap.get("wall_A_corner_double_backward");
            else
              return SpriteMap.get("wall_A_Quad");
          case 1:
            if (botLeftWall)
              return SpriteMap.get("wall_A_corner_triple_DL");
            else if (topLeftWall)
              return SpriteMap.get("wall_A_corner_triple_UL");
            else if (botRightWall)
              return SpriteMap.get("wall_A_corner_triple_DR");
            else
              return SpriteMap.get("wall_A_corner_triple_UR");
          }
        }
      }

    case FLOOR:
      {
        // Should be multi sprite instead
        return SpriteMap.get("question_mark");
      }
    case BLOCK:
      // Check if above target
      if (gameMap.bgLayer.GetNode(x, y).type == BlockType.TARGET)
        return SpriteMap.get("block_2");
      else
        return SpriteMap.get("block_1");
    case BLOCK_H:
      // Check if above target
      if (gameMap.bgLayer.GetNode(x, y).type == BlockType.TARGET)
        return SpriteMap.get("block_h_2");
      else
        return SpriteMap.get("block_h_1");
    case BLOCK_V:
      // Check if above target
      if (gameMap.bgLayer.GetNode(x, y).type == BlockType.TARGET)
        return SpriteMap.get("block_v_2");
      else
        return SpriteMap.get("block_v_1");
    case PLAYER:
      switch(flag)
      {
      default:
      case 4:
        if (TickCounter % 2 == 0)
          return SpriteMap.get("guy_1_right");
        else
          return SpriteMap.get("guy_1_right2");
      case 3:
        if (TickCounter % 2 == 0)
          return SpriteMap.get("guy_1_left");
        else
          return SpriteMap.get("guy_1_left2");
      case 1:
        if (TickCounter % 2 == 0)
          return SpriteMap.get("guy_1_up");
        else
          return SpriteMap.get("guy_1_up2");
      case 2:
        if (TickCounter % 2 == 0)
          return SpriteMap.get("guy_1_down");
        else
          return SpriteMap.get("guy_1_down2");
      }

    case SIGN:
      return SpriteMap.get("sign_1");
    case TARGET:
      return SpriteMap.get("target_1");

    default:
    case ERROR:
      return SpriteMap.get("question_mark");
    case NOTHING:
      return null;
    }
  }

  public void UpdateSprite(int x, int y)
  {
    // Multi Sprite
    if (type == BlockType.FLOOR)
    {
      sprite = null;
      multiSprite = true;

      boolean topFloor = gameMap.IsInsideBoard(x, y - 1) ? gameMap.bgLayer.GetNode(x, y - 1).type == BlockType.FLOOR : true;
      boolean botFloor = gameMap.IsInsideBoard(x, y + 1) ? gameMap.bgLayer.GetNode(x, y + 1).type == BlockType.FLOOR : true;
      boolean leftFloor = gameMap.IsInsideBoard(x - 1, y) ? gameMap.bgLayer.GetNode(x - 1, y).type == BlockType.FLOOR : true;
      boolean rightFloor = gameMap.IsInsideBoard(x + 1, y) ? gameMap.bgLayer.GetNode(x + 1, y).type == BlockType.FLOOR : true;
      boolean topLeftFloor = gameMap.IsInsideBoard(x - 1, y - 1) ? gameMap.bgLayer.GetNode(x - 1, y - 1).type == BlockType.FLOOR : true;
      boolean topRightFloor = gameMap.IsInsideBoard(x + 1, y - 1) ? gameMap.bgLayer.GetNode(x + 1, y - 1).type == BlockType.FLOOR : true;
      boolean botLeftFloor = gameMap.IsInsideBoard(x - 1, y + 1) ? gameMap.bgLayer.GetNode(x - 1, y + 1).type == BlockType.FLOOR : true;
      boolean botRightFloor = gameMap.IsInsideBoard(x + 1, y + 1) ? gameMap.bgLayer.GetNode(x + 1, y + 1).type == BlockType.FLOOR : true;

      // Up Left
      if (topFloor && leftFloor)
      {
        if (topLeftFloor)
          spriteCorners[0] = SpriteMap.get("floor_UL_5");
        else
          spriteCorners[0] = SpriteMap.get("floor_UL_4");
      } else if (topFloor)
        spriteCorners[0] = SpriteMap.get("floor_UL_3");
      else if (leftFloor)
        spriteCorners[0] = SpriteMap.get("floor_UL_2");
      else
        spriteCorners[0] = SpriteMap.get("floor_UL_1");

      // Up Right
      if (topFloor && rightFloor)
      {
        if (topRightFloor)
          spriteCorners[1] = SpriteMap.get("floor_UR_5");
        else
          spriteCorners[1] = SpriteMap.get("floor_UR_4");
      } else if (topFloor)
        spriteCorners[1] = SpriteMap.get("floor_UR_3");
      else if (rightFloor)
        spriteCorners[1] = SpriteMap.get("floor_UR_2");
      else
        spriteCorners[1] = SpriteMap.get("floor_UR_1");

      // Bot Left
      if (botFloor && leftFloor)
      {
        if (botLeftFloor)
          spriteCorners[2] = SpriteMap.get("floor_DL_5");
        else
          spriteCorners[2] = SpriteMap.get("floor_DL_4");
      } else if (botFloor)
        spriteCorners[2] = SpriteMap.get("floor_DL_3");
      else if (leftFloor)
        spriteCorners[2] = SpriteMap.get("floor_DL_2");
      else
        spriteCorners[2] = SpriteMap.get("floor_DL_1");

      // Bot Right
      if (botFloor && rightFloor)
      {
        if (botRightFloor)
          spriteCorners[3] = SpriteMap.get("floor_DR_5");
        else
          spriteCorners[3] = SpriteMap.get("floor_DR_4");
      } else if (botFloor)
        spriteCorners[3] = SpriteMap.get("floor_DR_3");
      else if (rightFloor)
        spriteCorners[3] = SpriteMap.get("floor_DR_2");
      else
        spriteCorners[3] = SpriteMap.get("floor_DR_1");
    }
    // Single Sprite
    else
    {
      sprite = GetSprite(x, y);
      multiSprite = false;

      spriteCorners[0] = null;
      spriteCorners[1] = null;
      spriteCorners[2] = null;
      spriteCorners[3] = null;
    }
  }
}
