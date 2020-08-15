
import java.util.Map;

boolean firstFrame = true;

GameMap gameMap = null;

float BlockSize;
float BlockSizeHalf;
float BlockSizeQuarter;
public void AdjustBlockSize(GameMap _gameMap)
{
  if (_gameMap.m_height == 0 || _gameMap.m_width == 0)
  {
    BlockSize = 0;
  }
  //
  else
  {
    // Check Vertical Space
    BlockSize = (height / _gameMap.m_height);
    // Is Horizontal stretching off screen
    if (_gameMap.m_width * BlockSize > width)
      BlockSize = (width / _gameMap.m_width);
  }
  //
  BlockSizeHalf = BlockSize / 2.0;
  BlockSizeQuarter = BlockSizeHalf / 2.0;
}

// Camera
Camera camera = new Camera();

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
boolean levelTransitionIsReset = false;

// Save effect
boolean saveEffect = false;
float saveEffectTime = 0.0f;

// Undo
boolean doingUndo = false;

// Ticks
int TickCounter = 0;
// Time
int lastTime = 0;
int delta = 0;
double deltaTime = 1;

// Colors
final color messageColor = color(250, 172, 160); //218, 85, 64

// Block Index for what mouse is hovering
PVector selectionPoint = new PVector(0, 0);


//
PShader shader_transition;

// Guis
Gui_BlockSelector gui_blockSelector = null;
Gui_LevelSettings gui_levelSettings = null;
Gui_LevelSelector gui_levelSelector = null;
// Gui Window
GuiWindow currentGuiWindow = null;

void setup()
{
  //
  size(1080, 720, P2D);

  // Setup Guis
  gui_levelSelector = new Gui_LevelSelector("Level - Selector", new PVector(100.0, 100.0), new PVector(500.0, 300.0), new PVector(160, 80));
  gui_levelSettings = new Gui_LevelSettings("Level - Settings", new PVector(100.0, 100.0), new PVector(500.0, 300.0), new PVector(160, 80));
  gui_blockSelector = new Gui_BlockSelector("Block - Selector", new PVector(100.0, 100.0), new PVector(500.0, 500.0), new PVector(160, 160));

  // remove image smoothing
  ((PGraphicsOpenGL)g).textureSampling(3); // the magic
  //noSmooth();

  // image always in center
  imageMode(CENTER);
  // Setup Assets
  SetupAssets();
  SetCurrentFont("8bit_30");

  // Shaders
  shader_transition = loadShader("Shaders/transitionEffect_Frag.glsl", "Shaders/transitionEffect_Vert.glsl");
  shader_transition.set("width", float(width));
  shader_transition.set("height", float(height));

  // Create Map
  LoadNextLevel();
}


void update()
{
  // Game
  if (gameMap == null)
  {
    if (Input.GetKeyDown(ENTER))
      LoadNextLevel();
  } else
  {

    // Editor Mode
    if (Input.GetKeyDown('x'))
    {
      Editor.enabled = !Editor.enabled;
      gameMap.SetReadingMessage(false);

      if (!Editor.enabled)
      {
        currentGuiWindow = null;
        gameMap.RecalculateTargetCount();
      }
    }
    //


    // Editor - Gui - Level Selector
    if (Editor.enabled)
    {
      // Save
      if (Input.GetKeyDown(' '))
      {
        saveEffect = true;
        saveEffectTime = 0.0f;
        SaveLevel();
      }
      // Block Level Complete
      else if (Input.GetKeyDown('q') || Input.GetKeyDown('Q'))
      {
        Editor.preventLevelCompletion = !Editor.preventLevelCompletion;
      }
      // Skip Level
      else if (Input.GetKeyDown('t') || Input.GetKeyDown('T'))
      {
        LoadNextLevel();
      }
      //
      else if (Input.GetKeyDown('1'))
      {
        if (currentGuiWindow == null)
        {
          currentGuiWindow = gui_levelSelector;
          currentGuiWindow.close = false;
          gui_levelSelector.refreshLevelSelection();
        }
        //
        else
          currentGuiWindow = null;
      }
      //
      else if (Input.GetKeyDown('2'))
      {
        if (currentGuiWindow == null)
        {
          currentGuiWindow = gui_levelSettings;
          currentGuiWindow.close = false;
        }
        //
        else
          currentGuiWindow = null;
      }
      //
      else if (Input.GetKeyDown(TAB))
      {
        if (currentGuiWindow == null)
        {
          currentGuiWindow = gui_blockSelector;
          currentGuiWindow.close = false;
        }
        //
        else
          currentGuiWindow = null;
      }
    }

    // Save effect
    if (saveEffect)
    {
      saveEffectTime += deltaTime;
      if (saveEffectTime >= 1.25)
        saveEffect = false;
    }

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
      {
        currentGuiWindow.update();

        // Update Input
        Input.EndUpdate();
        return;
      }
    }

    if (Editor.enabled)
    {
      // Block for Drawing
      //
      // Index Modification
      if (Input.GetScrollDelta() == -1.0)
        Editor.NextBlockDrawIndex(1);
      else  if (Input.GetScrollDelta() == 1.0)
        Editor.NextBlockDrawIndex(-1);


      // Update Selection
      //
      // Correct X/Y
      selectionPoint.x = mouseX - camera.getX();
      selectionPoint.y = mouseY - camera.getY();
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
          Editor.DrawBlock(x, y, gameMap);
        }
        //
        else if (Input.GetMouseButton(RIGHT))
        {
          Editor.EraseBlock(x, y, gameMap);
        } else if (Input.GetMouseButton(CENTER))
        {
          Editor.SelectBlock(x, y, gameMap);
        }
      }
    }

    // Update Map
    if (!Editor.enabled)
      gameMap.update();

    // Check if level is complete
    if (!Editor.enabled && !Editor.preventLevelCompletion && gameMap.targetsFilled >= gameMap.targetCount && gameMap.targetCount > 0)
    {
      // Initial Level Complete
      if (!levelTransitionMode)
      {
        EmitterController.add(new Emitter(
          width / 2.0, height / 2.0, // X, Y
          0.75, 26, // Lifetime, Count
          color(255), color(10), // Color (start/end)
          50, 0, // Size (start/end)
          6, 10, 0.2, // SpeedMin, SpeedMax, Drag
          new PVector(0, 1), 360 // Direction, AngleFuzz
          ));
      }

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
          // Reset
          if (levelTransitionIsReset)
          {
            ReloadLevel();
            levelTransitionIsReset = false;
          }
          // Next Level
          else
          {
            LoadNextLevel();
          }

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
      // Close Message
      gameMap.SetReadingMessage(false);

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

      // Reset
      if (Input.GetKeyDown('r') || Input.GetKeyDown('R'))
      {
        // Instant reset
        if (Editor.enabled)
        {
          ReloadLevel();
          EmitterController.clear();
        }
        // Reset only in transition mode
        else
        {
          levelTransitionMode = true;
          levelTransitionIsReset = true;
        }
      }
      // Read Message
      else if (Input.GetKeyDown(ENTER))
      {
        gameMap.SetReadingMessage(!gameMap.IsReadingMessage());
      }
      //
      if (!Editor.enabled)
      {
        boolean UpKey = Input.GetKey(UP) || Input.GetKey('w') || Input.GetKey('W');
        boolean DownKey = Input.GetKey(DOWN) || Input.GetKey('s') || Input.GetKey('S');
        boolean LeftKey = Input.GetKey(LEFT) || Input.GetKey('a') || Input.GetKey('A');
        boolean RightKey = Input.GetKey(RIGHT) || Input.GetKey('d') || Input.GetKey('D');

        if (UpKey && !DownKey)
          Move(Direction.UP);
        else  if (!UpKey && DownKey)
          Move(Direction.DOWN);
        else  if (LeftKey && !RightKey)
          Move(Direction.LEFT);
        else  if (RightKey && !LeftKey)
          Move(Direction.RIGHT);
        // undo
        else  if (Input.GetKey('z') || Input.GetKey('Z'))
        {
          Undo();
        }
      }
    }
    //

    // Emitters
    EmitterController.update();
  }

  // Update Input
  Input.EndUpdate();
}

void ReloadLevel()
{
  gameMap = new GameMap(gameMap.levelPath, gameMap.levelMap, gameMap.levelMessage);
  gameMap.UpdateAllSprites();
  EmitterController.clear();
}
void LoadNextLevel()
{
  ArrayList<File> levelFiles = GetAllLevelFiles();

  // No levels available == Load hardcoded level
  if (levelFiles.size() == 0)
  {
    gameMap = new GameMap("", ErrorLevel, "NULL");
    gameMap.UpdateAllSprites();
    return;
  }

  // If no level loaded or hardcoded level is used, load first one available
  else if (gameMap == null || gameMap.levelPath.isEmpty())
  {
    ImportLevel(new File(levelFiles.get(0).getPath()));
    return;
  }

  int indexMath = -2;
  for (int i = 0; i < levelFiles.size(); i++)
  {
    if (i == indexMath + 1)
    {
      ImportLevel(new File(levelFiles.get(i).getPath()));
      return;
    } else if (levelFiles.get(i).getPath().equals(gameMap.levelPath))
      indexMath = i;
  }
  // Load first level if reached last level
  ImportLevel(new File(levelFiles.get(0).getPath()));
}

// Used from editor to save state
void SaveLevel()
{
  String updatedLevelMap = "";

  for (int y = 0; y < gameMap.m_height; y++)
  {
    for (int x = 0; x < gameMap.m_width; x++)
    {
      if (gameMap.bgLayer.nodes[x][y].type != BlockType.NOTHING)
      {
        updatedLevelMap += (WriteMapChar(gameMap.bgLayer.nodes[x][y].type));
      } else if (gameMap.entityLayer.nodes[x][y].type != BlockType.NOTHING)
      {
        updatedLevelMap += (WriteMapChar(gameMap.entityLayer.nodes[x][y].type));
      } else
      {
        updatedLevelMap += ('0');
      }
    }
    updatedLevelMap += ("\n");
  }

  gameMap.levelMap = updatedLevelMap;
  gameMap.UpdateAllSprites();
}

void ImportLevel(File file)
{
  if (fileExists(file.getPath()))
  {
    //println("Loading Level: " + file.getName());
    String newMapLayout = "";
    String newMapMessage = "";
    //
    BufferedReader reader = createReader(file.getPath());
    String line = null;
    try {
      while ((line = reader.readLine()) != null) {
        if (newMapMessage.isEmpty())
        {
          String[] messageSplit = split(line, '\\');
          for (int i = 0; i < messageSplit.length; i++)
          {
            newMapMessage += messageSplit[i];
            if (i != messageSplit.length - 1)
              newMapMessage += '\n';
          }
        }
        //
        else
        {
          newMapLayout = newMapLayout + line + "\n";
        }

        //String[] pieces = split(line, TAB);
        //int x = int(pieces[0]);
        //int y = int(pieces[1]);
        //point(x, y);
      }
      reader.close();
      //
      gameMap = new GameMap(file.getPath(), newMapLayout, newMapMessage);
      gameMap.UpdateAllSprites();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    //
  }
}
void ExportLevel(File file)
{
  // Cancel
  if (file == null)
    return;

  // Make sure level auto-ends with .level extension
  file = changeExtension(file, ".level");

  //
  String desiredPath = file.getPath();

  // Write
  PrintWriter output = createWriter(desiredPath);
  if (gameMap.levelMessage.isEmpty())
    output.println("Insert Message Here\\Line2\\Line3");
  else
  {
    String[] messageSplit = split(gameMap.levelMessage, '\n');
    String finalMessage = "";
    for (int i = 0; i < messageSplit.length; i++)
    {
      finalMessage += messageSplit[i];
      if (i != messageSplit.length - 1)
        finalMessage += '\\';
    }

    output.println(finalMessage);
  }

  for (int y = 0; y < gameMap.m_height; y++)
  {
    for (int x = 0; x < gameMap.m_width; x++)
    {
      if (gameMap.entityLayer.nodes[x][y].type != BlockType.NOTHING)
      {
        output.print(WriteMapChar(gameMap.entityLayer.nodes[x][y].type));
      } else if (gameMap.bgLayer.nodes[x][y].type != BlockType.NOTHING)
      {
        output.print(WriteMapChar(gameMap.bgLayer.nodes[x][y].type));
      } else
      {
        output.print('0');
      }
    }
    output.print("\n");
  }
  output.flush();
  output.close();

  if (gui_levelSelector != null)
    gui_levelSelector.refreshLevelSelection();
}

//
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

    gameMap.entityLayer.nodes[x][y].flag = n.node.flag;
    gameMap.entityLayer.nodes[x][y].moveDirection = flipDirection(n.node.moveDirection);
  }

  animationMode = true;

  // Remove last event from undo stack
  gameMap.UndoEvents.remove(undoEvent);
}

//
void Move(Direction direction)
{
  doingUndo = false;
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
        gameMap.entityLayer.nodes[x][y].flag = getFlagFromDirection(direction);
        // Update Player Sprite
        gameMap.entityLayer.nodes[x][y].UpdateSprite(x, y);

        // Check if blocked
        if (
          gameMap.bgLayer.nodes[x+OffsetX][y+OffsetY].blockDirection == direction
          )
        {
          // Do nothing
        }
        // Check if next board spot is empty
        else if (
          gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].solid == false &&
          gameMap.bgLayer.nodes[x+OffsetX][y+OffsetY].solid == false
          )
        {
          gameMap.entityLayer.nodes[x][y].moveDirection = direction;
          //
          animationMode = true;
        }
        // Check if next board is moveable
        else if (
          (gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].pushable_h && (direction == Direction.LEFT || direction == Direction.RIGHT)) ||
          (gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].pushable_v && (direction == Direction.UP || direction == Direction.DOWN))
          )
        {
          // CanMove
          boolean CanMove = true;
          // Direction check
          boolean h_mode = (gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].pushable_h && (direction == Direction.LEFT || direction == Direction.RIGHT));
          boolean v_mode = (gameMap.entityLayer.nodes[x+OffsetX][y+OffsetY].pushable_v && (direction == Direction.UP || direction == Direction.DOWN));

          // Attempt to keep moving
          PVector futureCheck = DirectionOffset.copy();
          futureCheck.add(DirectionOffset);

          // Keep future checking until reached end of map or empty space
          while (
            CanMove &&
            gameMap.IsInsideBoard(x+int(futureCheck.x), y+int(futureCheck.y)) && // next spot is on board
            gameMap.bgLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].solid == false &&
            gameMap.entityLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].type != BlockType.NOTHING
            )
          {
            boolean BlockedPath = (gameMap.bgLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].blockDirection == direction);
            boolean CanPush = 
              (h_mode && gameMap.entityLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].pushable_h) ||
              (v_mode && gameMap.entityLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].pushable_v);

            // Check if allowed to make an additional hop
            if (!BlockedPath && CanPush)
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
          // Check if blocked path
          else if (gameMap.bgLayer.nodes[x+int(futureCheck.x)][y+int(futureCheck.y)].blockDirection == direction)
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

          float sizeT = BlockSize / 54.0;

          EmitterController.add(new Emitter(
            pos.x, pos.y, // X, Y
            0.35, 6, // Lifetime, Count
            color(255), color(10), // Color (start/end)
            10.0 * sizeT, 0, // Size (start/end)
            3 * sizeT, 5 * sizeT, 0.2, // SpeedMin, SpeedMax, Drag
            vel, 45 // Direction, AngleFuzz
            ));
        }
      }
    }
  }
}
