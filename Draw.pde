
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

  // Draw
  pushMatrix(); 
  translate(CameraPosition.x, CameraPosition.y);
  //
  DrawMapLayer(gameMap.bgLayer);
  DrawMapLayer(gameMap.entityLayer);
  //

  // End Draw
  popMatrix();

  // Selection on map
  if (gameMap.IsInsideBoard(int(selectionPoint.x), int(selectionPoint.y)))
  {
    stroke(255, 0, 0);
    PVector SelPos = GetNodePositionFromIndex(int(selectionPoint.x), int(selectionPoint.y));
    rect(SelPos.x, SelPos.y, BlockSize, BlockSize);
    noStroke();
  }

  // UI On Screen
  {
    float padding = 5;

    // Bar
    fill(50);
    rect(0, 0, width, 32 + padding * 2);

    // Targets
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
      
       image(
        SpriteMap.get("undo_icon").image, 
        xStart + 16 + padding, 16 + padding, 32, 32
        );

      String msg1 = "x";
      String msg2 = str(gameMap.UndoEvents.size());
      RenderText(msg1, xStart + 32 + padding * 2 + 2, 6, color(150), TEXTH.LEFT, 0.75);
      RenderText(msg2, xStart + 32 + padding * 2 + 24, 6, color(190), TEXTH.LEFT, 1);
    }
  }


  // Level Transition Effect
  if (levelTransitionMode)
  {
    // Shrinking Circle
    shader(shader_transition, TRIANGLES);
    shader_transition.set("t", 1.0 - levelTransitionTime);
    shader_transition.set("blockCountW", float(gameMap.m_width));
    shader_transition.set("blockCountH", float(gameMap.m_height));

    fill(255, 255, 255);
    rect(0, 0, width, height);

    resetShader();

    // Render Message
    if (levelTransitionOutro == false)
    {
      String msg = "LEVEL COMPLETE";
      RenderTextBG(msg, width/2.0, height/2.0, 25, color(255));
      RenderTextBG(msg, width/2.0, height/2.0, 15, color(0));
      RenderText(msg, width/2.0, height/2.0, color(255), TEXTH.CENTER, 1);
    }
  }

  // Emitters
  EmitterController.draw();
  
  // Gui if active
  if(currentGuiWindow != null)
  {
    fill(0,0,0,100);
    rect(0,0,width,height);
    currentGuiWindow.draw();
    currentGuiWindow.drawResizeButton();
  }
}
