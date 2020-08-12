
// Fonts
class Font
{
  public PFont font;
  public float fontHeight;

  public Font(String path, float h)
  {
    font = createFont(path, h);
    fontHeight = h;
  }
}

Font CurrentFont = null;
HashMap<String, Font> FontMap = new HashMap<String, Font>();
void SetCurrentFont(String name)
{
  CurrentFont = FontMap.get(name);
  if (CurrentFont != null)
    textFont(CurrentFont.font);
  else
    println("UNKNOWN FONT: " + name);
}

// Extensions
String PNG_EXTENSION = ".png";

// Textures
class Texture
{
  public PImage image;
  
  public Texture(String path)
  {
    image = loadImage(path);
    if(image == null)
      println("MISSING PATH: " + path);
  }
}
//
HashMap<String, Texture> TextureMap = new HashMap<String, Texture>();
public Texture GetTexture(String name)
{
  if (TextureMap.get(name) == null)
    TextureMap.put(name, new Texture("Textures/" + name + PNG_EXTENSION));

  return TextureMap.get(name);
}

//  Sprites
class Sprite
{
  public PImage image;
  public boolean flipHorizontally;
  public boolean flipVertically;

  Sprite(Texture tex, boolean flipH, boolean flipV)
  {
    if (tex == null)
    {
      println("Error loading null texture for sprite");
      image = null;
    } else
      image = tex.image;

    flipHorizontally = flipH;
    flipVertically = flipV;
  }
}
//
HashMap<String, Sprite> SpriteMap = new HashMap<String, Sprite>();

// Load
void SetupAssets()
{

  // Create All Fonts
  FontMap.put("8bit_30", new Font("Fonts/8bit16.ttf", 30));
  FontMap.put("8bithud", new Font("Fonts/8-bit-hud.ttf", 20));

  // Create all Sprites
  SpriteMap.put("title_card", new Sprite(GetTexture("title_card"), false, false));
  
  SpriteMap.put("question_mark", new Sprite(GetTexture("question_mark"), false, false));

  SpriteMap.put("undo_icon", new Sprite(GetTexture("undo_icon"), false, false));

  SpriteMap.put("sign_1", new Sprite(GetTexture("sign_1"), false, false));

  SpriteMap.put("block_1", new Sprite(GetTexture("block_1"), false, false));
  SpriteMap.put("block_2", new Sprite(GetTexture("block_2"), false, false));
  
  SpriteMap.put("block_h_1", new Sprite(GetTexture("block_h_1"), false, false));
  SpriteMap.put("block_h_2", new Sprite(GetTexture("block_h_2"), false, false));
  
  SpriteMap.put("block_v_1", new Sprite(GetTexture("block_v_1"), false, false));
  SpriteMap.put("block_v_2", new Sprite(GetTexture("block_v_2"), false, false));

  SpriteMap.put("guy_1_right", new Sprite(GetTexture("guy_1"), false, false));
  SpriteMap.put("guy_1_right2", new Sprite(GetTexture("guy_2"), false, false));
  SpriteMap.put("guy_1_left", new Sprite(GetTexture("guy_1"), true, false));
  SpriteMap.put("guy_1_left2", new Sprite(GetTexture("guy_2"), true, false));
  SpriteMap.put("guy_1_up", new Sprite(GetTexture("guy_3"), false, false));
  SpriteMap.put("guy_1_up2", new Sprite(GetTexture("guy_4"), false, false));
  SpriteMap.put("guy_1_down", new Sprite(GetTexture("guy_3"), false, true));
  SpriteMap.put("guy_1_down2", new Sprite(GetTexture("guy_4"), false, true));

  SpriteMap.put("floor_1", new Sprite(GetTexture("floor_1"), true, true));

  SpriteMap.put("target_1", new Sprite(GetTexture("target_1"), true, true));

  // Floors
  SpriteMap.put("floor_UL_1", new Sprite(GetTexture("floor/UL_1"), false, false));
  SpriteMap.put("floor_UL_2", new Sprite(GetTexture("floor/UL_2"), false, false));
  SpriteMap.put("floor_UL_3", new Sprite(GetTexture("floor/UL_3"), false, false));
  SpriteMap.put("floor_UL_4", new Sprite(GetTexture("floor/UL_4"), false, false));
  SpriteMap.put("floor_UL_5", new Sprite(GetTexture("floor/UL_5"), false, false));

  SpriteMap.put("floor_UR_1", new Sprite(GetTexture("floor/UR_1"), false, false));
  SpriteMap.put("floor_UR_2", new Sprite(GetTexture("floor/UR_2"), false, false));
  SpriteMap.put("floor_UR_3", new Sprite(GetTexture("floor/UR_3"), false, false));
  SpriteMap.put("floor_UR_4", new Sprite(GetTexture("floor/UR_4"), false, false));
  SpriteMap.put("floor_UR_5", new Sprite(GetTexture("floor/UR_5"), false, false));

  SpriteMap.put("floor_DL_1", new Sprite(GetTexture("floor/DL_1"), false, false));
  SpriteMap.put("floor_DL_2", new Sprite(GetTexture("floor/DL_2"), false, false));
  SpriteMap.put("floor_DL_3", new Sprite(GetTexture("floor/DL_3"), false, false));
  SpriteMap.put("floor_DL_4", new Sprite(GetTexture("floor/DL_4"), false, false));
  SpriteMap.put("floor_DL_5", new Sprite(GetTexture("floor/DL_5"), false, false));

  SpriteMap.put("floor_DR_1", new Sprite(GetTexture("floor/DR_1"), false, false));
  SpriteMap.put("floor_DR_2", new Sprite(GetTexture("floor/DR_2"), false, false));
  SpriteMap.put("floor_DR_3", new Sprite(GetTexture("floor/DR_3"), false, false));
  SpriteMap.put("floor_DR_4", new Sprite(GetTexture("floor/DR_4"), false, false));
  SpriteMap.put("floor_DR_5", new Sprite(GetTexture("floor/DR_5"), false, false));

  // Walls
  SpriteMap.put("wall_A_alone", new Sprite(GetTexture("wall_A_4"), false, false));

  SpriteMap.put("wall_A_single_top", new Sprite(GetTexture("wall_A_3"), false, false));
  SpriteMap.put("wall_A_single_bot", new Sprite(GetTexture("wall_A_3"), false, true));
  SpriteMap.put("wall_A_single_right", new Sprite(GetTexture("wall_A_12"), false, false));
  SpriteMap.put("wall_A_single_left", new Sprite(GetTexture("wall_A_12"), true, false));

  SpriteMap.put("wall_A_double_topbot", new Sprite(GetTexture("wall_A_9"), false, false));
  SpriteMap.put("wall_A_double_leftright", new Sprite(GetTexture("wall_A_13"), false, false));

  SpriteMap.put("wall_A_double_topleft", new Sprite(GetTexture("wall_A_2"), false, false));
  SpriteMap.put("wall_A_double_topright", new Sprite(GetTexture("wall_A_2"), true, false));
  SpriteMap.put("wall_A_double_botleft", new Sprite(GetTexture("wall_A_2"), false, true));
  SpriteMap.put("wall_A_double_botright", new Sprite(GetTexture("wall_A_2"), true, true));

  SpriteMap.put("wall_A_double_topleft_diag", new Sprite(GetTexture("wall_A_11"), false, false));
  SpriteMap.put("wall_A_double_topright_diag", new Sprite(GetTexture("wall_A_11"), true, false));
  SpriteMap.put("wall_A_double_botleft_diag", new Sprite(GetTexture("wall_A_11"), false, true));
  SpriteMap.put("wall_A_double_botright_diag", new Sprite(GetTexture("wall_A_11"), true, true));

  SpriteMap.put("wall_A_triple_top", new Sprite(GetTexture("wall_A_1"), false, false));
  SpriteMap.put("wall_A_triple_top_L", new Sprite(GetTexture("wall_A_8"), true, false));
  SpriteMap.put("wall_A_triple_top_R", new Sprite(GetTexture("wall_A_8"), false, false));
  SpriteMap.put("wall_A_triple_top_LR", new Sprite(GetTexture("wall_A_17"), false, false));

  SpriteMap.put("wall_A_triple_bot", new Sprite(GetTexture("wall_A_1"), false, true));
  SpriteMap.put("wall_A_triple_bot_L", new Sprite(GetTexture("wall_A_8"), true, true));
  SpriteMap.put("wall_A_triple_bot_R", new Sprite(GetTexture("wall_A_8"), false, true));
  SpriteMap.put("wall_A_triple_bot_LR", new Sprite(GetTexture("wall_A_17"), false, true));

  SpriteMap.put("wall_A_triple_left", new Sprite(GetTexture("wall_A_14"), false, false));
  SpriteMap.put("wall_A_triple_left_U", new Sprite(GetTexture("wall_A_19"), false, false));
  SpriteMap.put("wall_A_triple_left_D", new Sprite(GetTexture("wall_A_19"), false, true));
  SpriteMap.put("wall_A_triple_left_UD", new Sprite(GetTexture("wall_A_18"), false, false));

  SpriteMap.put("wall_A_triple_right", new Sprite(GetTexture("wall_A_14"), true, false));
  SpriteMap.put("wall_A_triple_right_U", new Sprite(GetTexture("wall_A_19"), true, false));
  SpriteMap.put("wall_A_triple_right_D", new Sprite(GetTexture("wall_A_19"), true, true));
  SpriteMap.put("wall_A_triple_right_UD", new Sprite(GetTexture("wall_A_18"), true, false));

  SpriteMap.put("wall_A_Quad", new Sprite(GetTexture("wall_A_10"), false, false));

  SpriteMap.put("wall_A_corner_triple_topright", new Sprite(GetTexture("wall_A_6"), false, false));
  SpriteMap.put("wall_A_corner_triple_botright", new Sprite(GetTexture("wall_A_6"), false, true));
  SpriteMap.put("wall_A_corner_triple_topleft", new Sprite(GetTexture("wall_A_6"), true, false));
  SpriteMap.put("wall_A_corner_triple_botleft", new Sprite(GetTexture("wall_A_6"), true, true));

  SpriteMap.put("wall_A_corner_double_up", new Sprite(GetTexture("wall_A_5"), false, false));
  SpriteMap.put("wall_A_corner_double_down", new Sprite(GetTexture("wall_A_5"), false, true));
  SpriteMap.put("wall_A_corner_double_right", new Sprite(GetTexture("wall_A_16"), false, false));
  SpriteMap.put("wall_A_corner_double_left", new Sprite(GetTexture("wall_A_16"), true, false));

  SpriteMap.put("wall_A_corner_double_forward", new Sprite(GetTexture("wall_A_7"), false, false));
  SpriteMap.put("wall_A_corner_double_backward", new Sprite(GetTexture("wall_A_7"), false, true));

  SpriteMap.put("wall_A_corner_triple_DL", new Sprite(GetTexture("wall_A_15"), false, false));
  SpriteMap.put("wall_A_corner_triple_DR", new Sprite(GetTexture("wall_A_15"), true, false));
  SpriteMap.put("wall_A_corner_triple_UL", new Sprite(GetTexture("wall_A_15"), false, true));
  SpriteMap.put("wall_A_corner_triple_UR", new Sprite(GetTexture("wall_A_15"), true, true));
}
