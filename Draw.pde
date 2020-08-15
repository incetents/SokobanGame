
private void DrawMapLayer(GameLayer layer)
{
  for (int x = 0; x < layer.m_width; x++)
  {
    for (int y = 0; y < layer.m_height; y++)
    {
      // Skip
      if (layer.nodes[x][y].type == BlockType.NOTHING)
        continue;

      layer.nodes[x][y].draw(x, y, layer);
    }
  }
}

void draw()
{
  // DeltaTime
  delta = (millis() - lastTime);
  deltaTime = delta / 1000.0; 
  lastTime = millis();     

  // Update
  if (firstFrame)
    firstFrame = false;
  else
    update();

  // Draw Start
  resetShader();
  background(0);
  noStroke();
  noFill();
  noClip(); // viewport is default window size

  // Title card
  if (gameMap == null)
  {
    image(SpriteMap.get("title_card").image, width/2.0, height/2.0, width, height);
    return;
  }


  // Draw
  pushMatrix(); 
  translate(camera.getX(), camera.getY());
  //
  DrawMapLayer(gameMap.bgLayer);
  DrawMapLayer(gameMap.entityLayer);
  //

  //  around level
  if (Editor.enabled)
  {
    noFill();
    stroke(0, 0, 255);
    rect(0, 0, gameMap.m_width * BlockSize, gameMap.m_height * BlockSize);

    stroke(255, 0, 255);
    rect(BlockSize/2.0, BlockSize/2.0, gameMap.m_width * BlockSize - BlockSize, gameMap.m_height * BlockSize - BlockSize);

    noStroke();
  }

  // End Draw
  popMatrix();

  // Selection on map
  if (Editor.enabled)
  {
    if (gameMap.IsInsideBoard(int(selectionPoint.x), int(selectionPoint.y)))
    {
      stroke(255, 0, 0);
      PVector SelPos = GetNodePositionFromIndex(int(selectionPoint.x), int(selectionPoint.y));
      rect(SelPos.x, SelPos.y, BlockSize, BlockSize);
      noStroke();
    }
  }

  // Emitters
  EmitterController.draw();

  // Enter prompt
  for (int x = 0; x < gameMap.m_width; x++)
  {
    for (int y = 0; y < gameMap.m_height; y++)
    {
      if (gameMap.entityLayer.nodes[x][y].type == BlockType.PLAYER)
      {
        if (gameMap.bgLayer.nodes[x][y].type == BlockType.SIGN)
        {
          PVector p = GetNodeCenterFromIndex(x, y);
          float t = (millis() % 2000) * TWO_PI / 2000.0;
          float y_offset = sin(t) * 6;
          RenderTextBG("ENTER", p.x, p.y - BlockSize + y_offset, 2, color(0, 0, 0, 150), TEXTH.CENTER, 1.0);
          RenderText("ENTER", p.x, p.y - BlockSize + y_offset, color(255), TEXTH.CENTER, 1.0);
        }
      }
    }
  }

  // Message on screen
  if (gameMap.IsReadingMessage())
  {
    float t = min(1, gameMap.readingMessageT * 4.0);

    final float msgBoxW = 1000;
    float msgBoxH = 390 * t;
    float msgBoxX = width/2.0 - msgBoxW / 2.0;
    float msgBoxY = height/2.0 - msgBoxH / 2.0;
    final float padding = 3;

    clip(msgBoxX + msgBoxW / 2.0, msgBoxY + msgBoxH / 2.0, msgBoxW + padding * 2, msgBoxH + padding * 2);

    fill(messageColor);
    rect(msgBoxX - padding, msgBoxY - padding, msgBoxW + padding * 2, msgBoxH + padding * 2);
    fill(0);
    rect(msgBoxX, msgBoxY, msgBoxW, msgBoxH);

    SetCurrentFont("8bithud");
    RenderText(gameMap.levelMessage, msgBoxX + 20, msgBoxY + 20, messageColor, TEXTH.LEFT, 1.0);
    SetCurrentFont("8bit_30");

    noClip();
  }

  // UI On Screen
  if (!Editor.enabled)
  {
    float padding = 5;

    // Bar
    fill(50, 50, 50, 150);
    rect(0, 0, width, 32 + padding * 2);

    // Targets
    if (!Editor.preventLevelCompletion)
    {
      float xStart = 0;

      image(
        SpriteMap.get("block_2").image, 
        xStart + 16 + padding, 16 + padding, 32, 32
        );

      String msg1 = "x";
      String msg2 = str(gameMap.targetsFilled) + "/" + str(gameMap.targetCount);
      RenderText(msg1, xStart + 32 + padding * 2 + 2, 6, color(150), TEXTH.LEFT, 0.75);
      RenderText(msg2, xStart + 32 + padding * 2 + 24, 6, color(190), TEXTH.LEFT, 1);
    }

    // Undos
    {
      float xStart = width - (32 + padding * 2 + 120);

      RenderText("(z)", xStart - 60, 6, color(150), TEXTH.LEFT, 1);

      image(
        SpriteMap.get("undo_icon").image, 
        xStart + 16 + padding, 16 + padding, 32, 32
        );

      String msg1 = "x";
      String msg2 = str(gameMap.UndoEvents.size());
      RenderText(msg1, xStart + 32 + padding * 2 + 2, 6, color(150), TEXTH.LEFT, 0.75);
      RenderText(msg2, xStart + 32 + padding * 2 + 24, 6, color(190), TEXTH.LEFT, 1);
    }

    // Level Name
    {
      RenderText(gameMap.levelName, width / 2.0, 2, color(200), TEXTH.CENTER, 1.0);
    }
  }

  // No completion mode
  if (Editor.preventLevelCompletion)
  {
    RenderText("LEVEL COMPLETE LOCKED", 5, 2, color(255, 255, 255, 100), TEXTH.LEFT, 0.75);
  }

  // UI Editor Info
  {
    float hStart = 62;
    float yStart = height - hStart;
    float fontYOffset = 2;

    // Bar
    if (Editor.enabled)
    {
      if (mouseY < yStart) 
      {
        fill(50, 50, 50, 150);
        rect(0, yStart, width, hStart);
      }
    }
    //
    else
    {
      yStart += 20;
      
      fill(50, 50, 50, 50);
      rect(0, yStart, 110, hStart);
    }


    // 
    RenderText("EditMode", 7, yStart - getFontHeight() / 2.0 + fontYOffset, color(150), TEXTH.LEFT, 0.5);
    if (Editor.enabled)
      RenderText("'x' [ON]", 7, yStart + fontYOffset, color(150), TEXTH.LEFT, 0.5);
    else
      RenderText("'x' [OFF]", 7, yStart + fontYOffset, color(150), TEXTH.LEFT, 0.5);

    if (Editor.enabled)
    {
      // Separator
      fill(50);
      rect(110, yStart, 4, hStart);

      // Block Selection
      Sprite imageSprite = SpriteMap.get(Editor.BlockDrawSpriteList.get(Editor.BlockDrawIndex));
      if (imageSprite != null)
      {
        image(imageSprite.image, 136, yStart + 28, 38, 38);
      }

      // Block Selection Text
      RenderText("SCRL - Change Block", 160, yStart - getFontHeight() / 2.0 + fontYOffset, color(150), TEXTH.LEFT, 0.5);
      RenderText("LMB - DRAW | RMB - ERASE", 160, yStart + fontYOffset, color(150), TEXTH.LEFT, 0.5);
      RenderText("SCRL CLICK - SELECT BLOCK", 160, yStart + fontYOffset +  getFontHeight() / 2.0, color(150), TEXTH.LEFT, 0.5);

      // Separator
      fill(50);
      rect(440, yStart, 4, hStart);

      // Shortcuts
      RenderText("'1' Level Selector", 448, yStart - getFontHeight() / 2.0 + fontYOffset, color(150), TEXTH.LEFT, 0.5);
      RenderText("'2' Map Settings", 448, yStart + fontYOffset, color(150), TEXTH.LEFT, 0.5);
      RenderText("'TAB' Block Selector", 448, yStart + fontYOffset + getFontHeight() / 2.0, color(150), TEXTH.LEFT, 0.5);

      RenderText("'SPACE' Save Level Internally", 680, yStart - getFontHeight() / 2.0 + fontYOffset, color(150), TEXTH.LEFT, 0.5);
      RenderText("'Q' Lock Level | 'T' Skip Level", 680, yStart + fontYOffset, color(150), TEXTH.LEFT, 0.5);
    }
  }

  // Level Transition Effect
  if (levelTransitionMode)
  {
    // Shrinking Circle
    shader(shader_transition, TRIANGLES);
    shader_transition.set("t", 1.0 - levelTransitionTime);
    shader_transition.set("blockCountW", float(max(12, gameMap.m_width)));
    shader_transition.set("blockCountH", float(max(12, gameMap.m_height)));

    fill(255, 255, 255);
    rect(0, 0, width, height);

    resetShader();

    // Render Message
    if (levelTransitionOutro == false && levelTransitionIsReset == false)
    {
      String msg = "LEVEL COMPLETE";
      RenderTextBG(msg, width/2.0, height/2.0, 25, color(255), TEXTH.CENTER, 1);
      RenderTextBG(msg, width/2.0, height/2.0, 15, color(0), TEXTH.CENTER, 1);
      RenderText(msg, width/2.0, height/2.0, color(255), TEXTH.CENTER, 1);
    }
  }

  // Empty Level TEXT
  if (gameMap.m_width == 0 || gameMap.m_height == 0)
    RenderText("EMPTY LEVEL", width/2.0, height/2.0, color(255), TEXTH.CENTER, 3.0);

  // Gui if active
  if (currentGuiWindow != null)
  {
    fill(0, 0, 0, 100);
    rect(0, 0, width, height);
    currentGuiWindow.draw();
    currentGuiWindow.drawResizeButton();
  }

  // Saving
  if (saveEffect)
  {
    RenderTextBG("SAVED LEVEL INTERALLY", width/2.0, height/2.0, 15, color(255), TEXTH.CENTER, 1.0);
    RenderTextBG("SAVED LEVEL INTERALLY", width/2.0, height/2.0, 5, color(0), TEXTH.CENTER, 1.0);
    RenderText("SAVED LEVEL INTERALLY", width/2.0, height/2.0, color(255), TEXTH.CENTER, 1.0);
  }
}
