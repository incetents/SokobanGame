
import java.util.Map;

boolean firstFrame = true;

GameMap gameMap = null;

float BlockSize;
float BlockSizeHalf;
float BlockSizeQuarter;
PVector CameraPosition = new PVector(0, 0);

// Animation Effect
boolean animationMode = false;
float animationTime = 0.0f;
float animationSpeed = 8.0f;
float animationUndoSpeed = 16.0f;

// Level Transition Effect
boolean levelTransitionMode = false;
boolean levelTransitionOutro = false;
float levelTransitionTime = 0.0f;
float levelTransitionIntroSpeed = 1.25f;
float levelTransitionOutroSpeed = 1.75f;

// Ticks
int TickCounter = 0;
// Time
int lastTime = 0;
int delta = 0;
double deltaTime = 1;

// Block Index for what mouse is hovering
PVector selectionPoint = new PVector(0, 0);

//
Direction lastPlayerDirection = Direction.RIGHT; 

//
boolean doingUndo = false;

//
PShader shader_transition;

// Gui Window
GuiWindow currentGuiWindow = null;

void setup()
{
  //
  size(1080, 720, P2D);

  // remove image smoothing
  ((PGraphicsOpenGL)g).textureSampling(3); // the magic
  //noSmooth();

  // image always in center
  imageMode(CENTER);
  // Setup Assets
  SetupAssets();
  SetCurrentFont("8bit");

  currentGuiWindow = new Gui_LevelSelector("Level - Selector", new PVector(100.0, 100.0), new PVector(500.0, 300.0), new PVector(160, 80));

  // Shaders
  shader_transition = loadShader("Shaders/transitionEffect_Frag.glsl", "Shaders/transitionEffect_Vert.glsl");
  shader_transition.set("width", float(width));
  shader_transition.set("height", float(height));

  // Create Map
  gameMap = new GameMap(levelLayout, 20);
  gameMap.UpdateAllSprites();

  // Fit to screen
  //
  // Check Vertical Space
  BlockSize = (height / gameMap.m_height);
  // Is Horizontal stretching off screen
  if (gameMap.m_width * BlockSize > width)
  {
    BlockSize = (width / gameMap.m_width);
    // Vertical Fix
    float y_offset = height - (BlockSize * gameMap.m_height);
    CameraPosition.y = round(y_offset / 2.0);
  } else
  {
    // Horizontal Fix
    float x_offset = width - (BlockSize * gameMap.m_width);
    CameraPosition.x = round(x_offset / 2.0);
  }
  BlockSizeHalf = BlockSize / 2.0;
  BlockSizeQuarter = BlockSizeHalf / 2.0;
}


void update()
{
  // Update Selection
  if (currentGuiWindow == null)
  {
    // New GUI
    if (Input.GetKey('1'))
    {
      // GUI
      currentGuiWindow = new Gui_LevelSelector("Level - Selector", new PVector(100.0, 100.0), new PVector(500.0, 300.0), new PVector(160, 80));
    }

    // Correct X/Y
    selectionPoint.x = mouseX - CameraPosition.x;
    selectionPoint.y = mouseY - CameraPosition.y;
    // Convert to Index
    selectionPoint.x = floor(selectionPoint.x / BlockSize);
    selectionPoint.y = floor(selectionPoint.y / BlockSize);

    // Check if selection is on the board
    if (gameMap.IsInsideBoard(selectionPoint.x, selectionPoint.y))
    {
      int x = int(selectionPoint.x);
      int y = int(selectionPoint.y);
      if (Input.GetMouseButton(LEFT))
      {
        gameMap.bgLayer.SetBlock(x, y, BlockType.WALL);
      } else if (Input.GetMouseButton(CENTER))
      {
        gameMap.bgLayer.SetBlock(x, y, BlockType.FLOOR);
      } else  if (Input.GetMouseButton(RIGHT))
      {
        gameMap.bgLayer.SetBlock(x, y, BlockType.NOTHING);
      }
    }
  }

  // Check if level is complete
  if (gameMap.targetsFilled >= gameMap.targetCount)
  {
    levelTransitionMode = true;
  }

  // Transition Mode Crap
  if (levelTransitionMode)
  {
    if (!levelTransitionOutro)
    {
      levelTransitionTime += deltaTime * levelTransitionIntroSpeed;
      levelTransitionTime = min(1.15, levelTransitionTime);
      if (levelTransitionTime >= 1.15)
      {
        gameMap = new GameMap(levelLayout, 20);
        gameMap.UpdateAllSprites();
        levelTransitionOutro = true;
      }
    } else
    {
      levelTransitionTime -= deltaTime * levelTransitionOutroSpeed;
      levelTransitionTime = max(0, levelTransitionTime);
      if (levelTransitionTime <= 0.0)
      {
        levelTransitionOutro = false;
        levelTransitionMode = false;
      }
    }
  }
  // Animation Crap
  else if (animationMode)
  {
    if (doingUndo)
      animationTime += deltaTime * animationUndoSpeed;
    else
      animationTime += deltaTime * animationSpeed;

    animationTime = min(1, animationTime);

    // Check end of transition mode
    if (animationTime >= 1.0f)
    {
      animationMode = false;
      animationTime = 0.0;
      gameMap.MovementTick(!doingUndo);
    }
  }
  // Await input from player
  else
  {
    // Reset flags
    levelTransitionTime = 0.0;
    animationTime = 0.0;
    levelTransitionOutro = false;
    //

    // TEST
    if (Input.GetKey('r'))
      levelTransitionMode = true;

    else if (Input.GetKey(UP) && !Input.GetKey(DOWN))
      Move(Direction.UP);
    else  if (!Input.GetKey(UP) && Input.GetKey(DOWN))
      Move(Direction.DOWN);
    else  if (Input.GetKey(LEFT) && !Input.GetKey(RIGHT))
      Move(Direction.LEFT);
    else  if (Input.GetKey(RIGHT) && !Input.GetKey(LEFT))
      Move(Direction.RIGHT);

    // undo
    else  if (Input.GetKey('z'))
    {
      Undo();
    }
  }
  //

  // Emitters
  EmitterController.update();

  // Hovered Button
  hoveredButton = null;
  if (!mousePressed)
    pressedButton = null;
  // GUI
  if (currentGuiWindow != null)
  {
    if (currentGuiWindow.close)
    {
      currentGuiWindow = null;
      draggedButton = null;
    } else
      currentGuiWindow.update();
  }

  // Update Input
  Input.EndUpdate();
}

void Undo()
{
  // Check if undo is available
  if (gameMap.UndoEvents.size() == 0)
    return;

  doingUndo = true;

  GameUndoEvent undoEvent = gameMap.UndoEvents.get(gameMap.UndoEvents.size() - 1);
  ArrayList<MovingNode> undoNodes = undoEvent.nodes;

  for (MovingNode n : undoNodes)
  {
    int x = int(n.position.x);
    int y = int(n.position.y);

    gameMap.entityLayer.nodes[x][y].moveDirection = flipDirection(n.node.moveDirection);
  }

  animationMode = true;

  // Remove last event from undo stack
  gameMap.UndoEvents.remove(undoEvent);
}



void Move(Direction direction)
{
  doingUndo = false;
  //
  lastPlayerDirection = direction;
  //

  // Target Direction
  PVector DirectionOffset = GetDirectionOffset(direction);
  int OffsetX = int(DirectionOffset.x);
  int OffsetY = int(DirectionOffset.y);

  // Find Players
  for (int x = 0; x < gameMap.m_width; x++)
  {
    for (int y = 0; y < gameMap.m_height; y++)
    {
      // Player found
      if (gameMap.entityLayer.nodes[x][y].type == BlockType.PLAYER && gameMap.IsInsideBoard(x+OffsetX, y+OffsetY))
      {
        // Update Player Sprite
        gameMap.entityLayer.nodes[x][y].UpdateSprite(x, y);

        // Check if next board spot is empty
        if (
          gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].solid == false &&
          gameMap.bgLayer.nodes[x+OffsetX][y+OffsetY].solid == false
          )
        {
          gameMap.entityLayer.nodes[x][y].moveDirection = direction;
          //
          animationMode = true;
        }
        // Check if next board is moveable
        else if (gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].pushable)
        {
          // CanMove
          boolean CanMove = true;

          // Attempt to keep moving
          PVector futureCheck = DirectionOffset.copy();
          futureCheck.add(DirectionOffset);

          // Keep future checking until reached end of map or empty space
          while (
            CanMove &&
            gameMap.IsInsideBoard(x+int(futureCheck.x), y+int(futureCheck.y)) &&
            gameMap.bgLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].solid == false &&
            gameMap.entityLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].type != BlockType.NOTHING
            )
          {
            // Check if allowed to make an additional hop
            if (
              gameMap.entityLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].pushable
              )
            {
              futureCheck.add(DirectionOffset);
            } else
              CanMove = false;
          }
          // Done, check if outside board
          if (!gameMap.IsInsideBoard(x+int(futureCheck.x), y+int(futureCheck.y)))
            CanMove = false;
          // Check if touching a solid block
          else if (gameMap.bgLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].solid == true)
            CanMove = false;

          // If can move is allowed, then move everything
          if (CanMove)
          {
            PVector Start = new PVector(x, y);
            PVector End = new PVector(x + futureCheck.x, y + futureCheck.y);

            while (Start.x != End.x || Start.y != End.y)
            {
              Node entNode = gameMap.entityLayer.nodes[int(Start.x)][int(Start.y)];

              entNode.moveDirection = direction;
              entNode.UpdateSprite(int(Start.x), int(Start.y));
              Start.add(DirectionOffset);
            }

            //
            animationMode = true;
          }
        }
        // If Animation Mode occurs, player trail
        if (animationMode)
        {
          // Trail for Character
          PVector pos = GetNodeCenterFromIndex(x, y);
          PVector vel = GetDirectionOffset(flipDirection(direction));

          EmitterController.add(new Emitter(
            pos.x, pos.y, // X, Y
            0.35, 6, // Lifetime, Count
            color(255), color(10), // Color (start/end)
            10, 0, // Size (start/end)
            3, 5, 0.2, // SpeedMin, SpeedMax, Drag
            vel, 45 // Direction, AngleFuzz
            ));
        }
      }
    }
  }
}
