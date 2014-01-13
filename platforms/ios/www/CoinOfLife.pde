/* @pjs font="Clock.ttf, Button.ttf"; crisp=true; */
/* @pjs preload="coin.png, button.png, active_button.png, gem.png, diamond.png, rock.png, logo.png, soundon.png, soundoff.png, 0.png, 1.png, 2.png, 3.png, 4.png, 5.png, 6.png, 7.png, 8.png, 9.png"; crisp="true"; */                 
/* @pjs preload="play.wav, coin.wav"; */ 
import apwidgets.*;

Player player;
Drawer drawer;
TutDrawer tut_drawer;
StoreDrawer store_drawer;

PImage G_COIN_IMAGE, G_BUTTON_IMAGE, G_ACTIVE_BUTTON_IMAGE, G_GEM_IMAGE, G_DIAMOND_IMAGE, G_ROCK_IMAGE, G_HIT_IMAGE, G_LOGO_IMAGE, G_SOUNDON_IMAGE, G_SOUNDOFF_IMAGE;
PImage[] G_DIGIT_IMAGES;

PFont G_CLOCK_FONT, G_BUTTON_FONT;

// Audio Setting
// Minim
Maxim G_PLAY_MAXIM;

// AudioPlayers
AudioPlayer G_PLAY_PLAYER, G_COIN_PLAYER;

// Timer for playing coin sound
int G_TIMER;

// Global sound State
boolean G_SOUND_STATE;

void setup() {
  // Setting up background and colors
  background(0);
  size(1024, 750);
  frameRate(30);
  //orientation(LANDSCAPE);
  //stroke(255);
  
  // Preload images
  G_COIN_IMAGE = loadImage("coin.png");
  G_BUTTON_IMAGE = loadImage("button.png");
  G_ACTIVE_BUTTON_IMAGE = loadImage("active_button.png");
  
  G_DIGIT_IMAGES = new PImage[10];
  for (int i = 0; i < 10; i++)
    G_DIGIT_IMAGES[i] = loadImage(i + ".png");
  G_GEM_IMAGE = loadImage("gem.png");
  G_DIAMOND_IMAGE = loadImage("diamond.png");
  G_ROCK_IMAGE = loadImage("rock.png");
  G_HIT_IMAGE = loadImage("hit.png");

  G_LOGO_IMAGE = loadImage("logo.png");
  
  // Sound images
  G_SOUNDON_IMAGE = loadImage("soundon.png");
  G_SOUNDOFF_IMAGE = loadImage("soundoff.png");
  
  // Preload font
  G_CLOCK_FONT = createFont("Clock.ttf", 48);
  G_BUTTON_FONT = createFont("Button.ttf", 24);
  
  // Create Maxim and AudioPlayers
  G_PLAY_MAXIM = new Maxim(this);
  
  G_PLAY_PLAYER = G_PLAY_MAXIM.loadFile("play.wav");
  G_COIN_PLAYER = G_PLAY_MAXIM.loadFile("coin.wav");
  //G_PLAY_PLAYER = new APMediaPlayer(this);
  //G_PLAY_PLAYER.setMediaFile("data/play.wav");
  G_PLAY_PLAYER.setLooping(false);
  
  //G_COIN_PLAYER = new APMediaPlayer(this);
  //G_COIN_PLAYER.setMediaFile("data/coin.wav");
  G_COIN_PLAYER.setLooping(false);
  
  // Set Sound State
  G_SOUND_STATE = true;
  
  int a_width = arena_width();
  int c_width = cell_width();
  int a_height = arena_height();
  int c_height = cell_height();
  int max_grid_x = max_grid_X();
  int max_grid_y = max_grid_Y();
  player = new Player(a_width, c_width, a_height, c_height, max_grid_x, max_grid_y);
  drawer = new Drawer(player);
  tut_drawer = new TutDrawer(player);
}

void draw() {
  if (player.getState() == Player.MENU) {
    player.getMenu().display();
  }
  else if (player.getState() == Player.NEXTLEVEL) {
    player.getGlobalMenu().display(player.getLevel());
  }
  else if (player.getState() >= Player.TUT) {
    if (player.getState() == Player.TUT_SIMULATING) 
      player.simulate();
    tut_drawer.drawit(player.get_a_width(), player.get_c_width(), player.get_a_height(), player.get_c_height());
  }
  else if (player.getState() == Player.STORE_INIT) {
    player.getStoreDrawer().drawit(player.get_a_width(), player.get_c_width(), player.get_a_height(), player.get_c_height());
  }
  else {
    if (player.getState() == Player.SIMULATING) { 
      player.simulate();
    }
    if (player.getState() == Player.TIMEOUT) {
      player.advanceScorers();
    }
    if (player.getState() == Player.FINISHED) {
      player.waitForNextLevel();
    }
    drawer.drawit(player.get_a_width(), player.get_c_width(), player.get_a_height(), player.get_c_height());
  }
}

void mouseReleased() {
  player.mouseReleased();
}

void mousePressed() {
  player.mousePressed();
}

public class Board {
  
  public Board(int level, int max_grid_x, int max_grid_y) {
    this.level = level;
    this.max_grid_x = max_grid_x;
    this.max_grid_y = max_grid_y;
    // Declare arrays
    alive = new boolean[max_grid_x+2][max_grid_y+2];
    ever_alive = new boolean[max_grid_x+2][max_grid_y+2];
    gem_positions = new boolean[max_grid_x+2][max_grid_y+2];
    diamond_positions = new boolean[max_grid_x+2][max_grid_y+2];
    rock_positions = new boolean[max_grid_x+2][max_grid_y+2];
    hit_positions = new boolean[max_grid_x+2][max_grid_y+2];
    
    last_X = new ArrayList();
    last_Y = new ArrayList();
    
    init(this.level);
  }
  
  public void init(int level) {
    for (int i = 0; i < this.max_grid_x+2; i++) {
      for (int j = 0; j < this.max_grid_y+2; j++) {
        alive[i][j] = false;
        ever_alive[i][j] = false;
        gem_positions[i][j] = false;
        diamond_positions[i][j] = false;
        rock_positions[i][j] = false;
        hit_positions[i][j] = false;
      }
    }
    
    // Randomly set gems
    for (int i = 1; i <= this.max_grid_x; i++) {
      for (int j = 2; j <= this.max_grid_y; j++) {
        double r = random(0., 0.5);
        if (r < 0.00692)
          gem_positions[i][j] = true;
        else if (r < 0.010380)
          diamond_positions[i][j] = true;
        else if (r < 0.01384)
          rock_positions[i][j] = true;
      }
    }
    
    last_X.clear();
    last_Y.clear();
  }
  
  // Getters
  public boolean[][] getAlive() { 
    return alive;
  }
  public boolean[][] getEverAlive() { 
    return ever_alive;
  }
  public boolean[][] getGemPositions() {
    return gem_positions;
  }
  public boolean[][] getDiamondPositions() {
    return diamond_positions;
  }
  public boolean[][] getRockPositions() {
    return rock_positions;
  }
  public boolean[][] getHitPositions() {
    return hit_positions;
  }
  
  public void placeCoin() {
    int c_width = cell_width();
    int c_height = cell_height();
    int i = (int) (mouseX /  c_width);
    int j = (int) (mouseY / c_height);
    if (gem_positions[i][j] || diamond_positions[i][j] || rock_positions[i][j])
      return;
    if (j <= 1) return;
    alive[i][j] = true;
    ever_alive[i][j] = true;
    last_X.add(0, i);
    last_Y.add(0, j);
  }
  
  // Responds to undo press by user
  public void undo() {
    int lx = last_X.get(0);
    int ly = last_Y.get(0);
    alive[lx][ly] = false;
    ever_alive[lx][ly] = false;
    last_X.remove(0);
    last_Y.remove(0);
  }
  
  // Responds to reset pressed by user
  public void reset() {
    for (int i = 0; i <= max_grid_x; i++) {
      for (int j = 0; j < max_grid_y; j++) {
        alive[i][j] = false;
        ever_alive[i][j] = false;
      }
    }
    while (!last_X.isEmpty ()) {
      last_X.remove(0);
      last_Y.remove(0);
    }
  }
  
  
  // Check if a cell is alive
  public boolean isAlive(int c_i, int c_j) {
    int alive_neighbors = 0;
    
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) {
          continue;
        }
        int new_ci = (c_i + i) % max_grid_x;
        int new_cj = (c_j + j) % max_grid_y;
        // Adjust the indices if out of arena
        if (new_ci < 1) {
          new_ci += max_grid_x;
        }
        if (new_cj < 1) {
          new_cj += max_grid_y;
        }

        if (alive[new_ci][new_cj]) {
          alive_neighbors++;
        }
      }
    }
    return ((alive[c_i][c_j] && alive_neighbors == 2) || alive_neighbors == 3);
  }
  
  
  // Simulate the board
  public int[] simulate() {
    int coin_increment = 0;
    int gem_increment = 0;
    int diamond_increment = 0;
    int rock_increment = 0;
    
    boolean temp_alive[][] = new boolean[max_grid_x+2][max_grid_y+2]; 
    for (int i = 1; i <= max_grid_x; i++) {
      for (int j = 1; j <= max_grid_y; j++) {
        if (isAlive(i, j)) {
          temp_alive[i][j] = true;
          if (gem_positions[i][j] || diamond_positions[i][j] || rock_positions[i][j]) {
            hit_positions[i][j] = true;
            if (gem_positions[i][j])
              gem_increment++;
            else if (diamond_positions[i][j])
              diamond_increment++;
            else if (rock_positions[i][j])
              rock_increment++;
          }
          gem_positions[i][j] = false;
          diamond_positions[i][j] = false;
          rock_positions[i][j] = false;
          
          if (!ever_alive[i][j]) {
            ever_alive[i][j] = true;
            if (j > 1)
              coin_increment++;
          }
        }
        else {
          temp_alive[i][j] = false;
        }
      }
    }  
    arrayCopy(temp_alive, alive);
    
    // Create array
    int[] ret = new int[4];
    ret[0] = coin_increment;
    ret[1] = gem_increment;
    ret[2] = diamond_increment;
    ret[3] = rock_increment;
    return ret;
  }
  
   
  // Level
  private int level;
  
  // Dimensions
  private int max_grid_x, max_grid_y;
  
  // Arrays to check if a cell is dead/alive
  private boolean alive[][];
  private boolean ever_alive[][];
  private ArrayList<Integer> last_X, last_Y;

  // Gems and Rocks on the grid
  private boolean gem_positions[][]; 
  private boolean diamond_positions[][];
  private boolean rock_positions[][];
 private boolean hit_positions[][]; 
}
public class CoinButton {

  // Constructor
  public CoinButton(int x, int y, int wd, int ht, String txt) {
    this.x = x;
    this.y = y;
    this.wd = wd;
    this.ht = ht;
    this.txt = txt;
    this.button = new Button(txt, x, y, wd, ht);
    this.button.setInactiveImage(G_BUTTON_IMAGE);
    this.button.setActiveImage(G_ACTIVE_BUTTON_IMAGE);
  }

  // drawit
  public void drawit() {
    //stroke(255);
    //fill(0);
    //image(G_BUTTON_IMAGE, x, y, wd, ht);
    pushStyle();
    fill(0);
    this.button.display();
    popStyle();
    //textSize(20);
    //text(txt, x + 3 * c_width, (int)(y + 1.5 * c_height));
  }
  
  // check if mouse-cliked inside the button
  public boolean mouseReleased() {
    return this.button.mouseReleased();
  }
  
  public boolean mousePressed() {
    return this.button.mousePressed();
  }
  
  // Getter
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getWidth() {
    return wd;
  }
  int getHeight() {
    return ht;
  }
  
  //private
  private int x;
  private int y;
  private int wd;
  private int ht;
  private String txt;
  private Button button;
}

public class Drawer {
  // Constructor
  public Drawer(Player p) {
    player = p;
  }

  // drawit
  public void drawit(int a_width, int c_width, int a_height, int c_height) {
    // Setting up background and colors
    background(0);
    stroke(255);
    int n_horizontal = (int)(a_width / c_width);
    int n_vertical = (int)(a_height / c_height);
    
    // Draw all the cells
    for (int i = 1; i < n_horizontal; i++) {
      line(i * c_width, 2 * c_height, i * c_width, n_vertical * c_height);
    }
    for (int i = 2; i <= n_vertical; i++) {
      line(c_width, i * c_height, (n_horizontal - 1) * c_width, i * c_height);
    }

    // Draw coins in cells
    boolean[][] alive = player.getAlive();
    boolean[][] ever_alive = player.getEverAlive();
    boolean[][] gem_positions = player.getGemPositions();
    boolean[][] diamond_positions = player.getDiamondPositions();
    boolean[][] rock_positions = player.getRockPositions();
    boolean[][] hit_positions = player.getHitPositions();
    
    for (int i = 0; i < alive.length; i++) {
      for (int j = 2; j < alive[i].length; j++) {
        if (ever_alive[i][j]) {
          pushStyle();
          fill(75, 75, 75);
          rect(i * c_width, j * c_height, c_width, c_height);
          popStyle();
        }
        if (alive[i][j]) {
          imageMode(CORNER);
          image(G_COIN_IMAGE, i * c_width, j * c_height, c_width, c_height);
        }
        if (gem_positions[i][j]) {
          imageMode(CORNER);
          image(G_GEM_IMAGE, i * c_width, j * c_height, (int)(c_width * 1.1), (int)(c_height * 1.1));
        }
        if (diamond_positions[i][j]) {
          imageMode(CORNER);
          image(G_DIAMOND_IMAGE, i * c_width, j * c_height, (int)(c_width * 1.1), (int)(c_height * 1.1));
        }
        if (rock_positions[i][j]) {
          imageMode(CORNER);
          image(G_ROCK_IMAGE, i * c_width, j * c_height, (int)(c_width * 1.1), (int)(c_height * 1.1));
        }
        if (hit_positions[i][j]) {
          imageMode(CENTER);
          image(G_HIT_IMAGE, (int)((i+0.5) * c_width), (int)((j+0.5) * c_height), (int)(c_width * 1.8), (int)(c_height * 1.8));
        }
      }
    }
    
    // Draw the buttons
    player.get_play_button().drawit();
    player.get_undo_button().drawit();
    player.get_reset_button().drawit();

    // Draw the timer
    player.getTimer().drawit(a_width, c_width, a_height, c_height);
    
    // Draw the scorer
    player.getCoinScorer().drawit();
    player.getGemScorer().drawit();
    player.getDiamondScorer().drawit();
    player.getRockScorer().drawit();
  }

  //private
  private Player player;
}


int HORIZONTAL = 0;
int VERTICAL   = 1;
int UPWARDS    = 2;
int DOWNWARDS  = 3;

class Widget
{

  
  PVector pos;
  PVector extents;
  String name;

  color inactiveColor = color(60, 60, 100);
  color activeColor = color(100, 100, 160);
  color bgColor = inactiveColor;
  color lineColor = color(255);
  
  
  
  void setInactiveColor(color c)
  {
    inactiveColor = c;
    bgColor = inactiveColor;
  }
  
  color getInactiveColor()
  {
    return inactiveColor;
  }
  
  void setActiveColor(color c)
  {
    activeColor = c;
  }
  
  color getActiveColor()
  {
    return activeColor;
  }
  
  void setLineColor(color c)
  {
    lineColor = c;
  }
  
  color getLineColor()
  {
    return lineColor;
  }
  
  String getName()
  {
    return name;
  }
  
  void setName(String nm)
  {
    name = nm;
  }


  Widget(String t, int x, int y, int w, int h)
  {
    pos = new PVector(x, y);
    extents = new PVector (w, h);
    name = t;
    //registerMethod("mouseEvent", this);
  }

  void display()
  {
  }

  boolean isClicked()
  {
    if (mouseX > pos.x && mouseX < pos.x+extents.x 
      && mouseY > pos.y && mouseY < pos.y+extents.y)
    {
      //println(mouseX + " " + mouseY);
      return true;
    }
    else
    {
      return false;
    }
  }
  
  public void mouseEvent(MouseEvent event)
  {
    //if (event.getFlavor() == MouseEvent.PRESS)
    //{
    //  mousePressed();
    //}
  }
  
  
  boolean mousePressed()
  {
    return isClicked();
  }
  
  boolean mouseDragged()
  {
    return isClicked();
  }
  
  
  boolean mouseReleased()
  {
    return isClicked();
  }
}

class Button extends Widget
{
  PImage activeImage = null;
  PImage inactiveImage = null;
  PImage currentImage = null;
  color imageTint = color(255);
  
  Button(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }
  
  void setImage(PImage img)
  {
    setInactiveImage(img);
    setActiveImage(img);
  }
  
  void setInactiveImage(PImage img)
  {
    if(currentImage == inactiveImage || currentImage == null)
    {
      inactiveImage = img;
      currentImage = inactiveImage;
    }
    else
    {
      inactiveImage = img;
    }
  }
  
  void setActiveImage(PImage img)
  {
    if(currentImage == activeImage || currentImage == null)
    {
      activeImage = img;
      currentImage = activeImage;
    }
    else
    {
      activeImage = img;
    }
  }
  
  void setImageTint(color c)
  {
    imageTint = c;
  }

  void display()
  {
    if(currentImage != null)
    {
      //float imgHeight = (extents.x*currentImage.height)/currentImage.width;
      //float imgWidth = (extents.y*currentImage.width)/currentImage.height;
      float imgWidth = extents.x;
      
      pushStyle();
      imageMode(CORNER);
      //tint(imageTint);
      image(currentImage, pos.x, pos.y, imgWidth, extents.y);
      textAlign(CENTER, CENTER);
      textFont(G_BUTTON_FONT, 24);
      text(name, pos.x + 0.5*extents.x, pos.y + 0.5* extents.y);
      //noTint();
      popStyle();
    }
    else
    {
      pushStyle();
      stroke(lineColor);
      fill(bgColor);
      rect(pos.x, pos.y, extents.x, extents.y);
  
      fill(lineColor);
      textAlign(CENTER, CENTER);
      text(name, pos.x + 0.5*extents.x, pos.y + 0.5* extents.y);
      popStyle();
    }
  }
  
  boolean mousePressed()
  {
    if (super.mousePressed())
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
      return true;
    }
    return false;
  }
  
  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
      return true;
    }
    return false;
  }
}

class Toggle extends Button
{
  boolean on = false;

  Toggle(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }


  boolean get()
  {
    return on;
  }

  void set(boolean val)
  {
    on = val;
    if (on)
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
    }
    else
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
    }
  }

  void toggle()
  {
    set(!on);
  }

  
  boolean mousePressed()
  {
    return super.isClicked();
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      toggle();
      return true;
    }
    return false;
  }
}

class RadioButtons extends Widget
{
  public Toggle [] buttons;
  
  RadioButtons (int numButtons, int x, int y, int w, int h, int orientation)
  {
    super("", x, y, w*numButtons, h);
    buttons = new Toggle[numButtons];
    for (int i = 0; i < buttons.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x+i*(w+5);
        by = y;
      }
      else
      {
        bx = x;
        by = y+i*(h+5);
      }
      buttons[i] = new Toggle("", bx, by, w, h);
    }
  }
  
  void setNames(String [] names)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(i >= names.length)
        break;
      buttons[i].setName(names[i]);
    }
  }
  
  void setImage(int i, PImage img)
  {
    setInactiveImage(i, img);
    setActiveImage(i, img);
  }
  
  void setAllImages(PImage img)
  {
    setAllInactiveImages(img);
    setAllActiveImages(img);
  }
  
  void setInactiveImage(int i, PImage img)
  {
    buttons[i].setInactiveImage(img);
  }

  
  void setAllInactiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setInactiveImage(img);
    }
  }
  
  void setActiveImage(int i, PImage img)
  {
    buttons[i].setActiveImage(img);
  }
  
  
  
  void setAllActiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setActiveImage(img);
    }
  }

  void set(String buttonName)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].getName().equals(buttonName))
      {
        buttons[i].set(true);
      }
      else
      {
        buttons[i].set(false);
      }
    }
  }
  
  int get()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return i;
      }
    }
    return -1;
  }
  
  String getString()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return buttons[i].getName();
      }
    }
    return "";
  }

  void display()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].display();
    }
  }

  boolean mousePressed()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mousePressed())
      {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseReleased())
      {
        for(int j = 0; j < buttons.length; j++)
        {
          if(i != j)
            buttons[j].set(false);
        }
        //buttons[i].set(true);
        return true;
      }
    }
    return false;
  }
}

class Slider extends Widget
{
  float minimum;
  float maximum;
  float val;
  int textWidth = 60;
  int orientation = HORIZONTAL;

  Slider(String nm, float v, float min, float max, int x, int y, int w, int h, int ori)
  {
    super(nm, x, y, w, h);
    val = v;
    minimum = min;
    maximum = max;
    orientation = ori;
    if(orientation == HORIZONTAL)
      textWidth = 60;
    else
      textWidth = 20;
  }

  float get()
  {
    return val;
  }

  void set(float v)
  {
    val = v;
    val = constrain(val, minimum, maximum);
  }

  void display()
  {
    pushStyle();
    textAlign(LEFT, TOP);
    fill(lineColor);
    text(name, pos.x, pos.y);
    stroke(lineColor);
    noFill();
    if(orientation ==  HORIZONTAL){
      rect(pos.x+textWidth, pos.y, extents.x-textWidth, extents.y);
    } else {
      rect(pos.x, pos.y+textWidth, extents.x, extents.y-textWidth);
    }
    noStroke();
    fill(bgColor);
    float sliderPos; 
    if(orientation ==  HORIZONTAL){
        sliderPos = map(val, minimum, maximum, 0, extents.x-textWidth-4); 
        rect(pos.x+textWidth+2, pos.y+2, sliderPos, extents.y-4);
    } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2, extents.x-4, sliderPos);
    } else if(orientation == UPWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2 + (extents.y-textWidth-4-sliderPos), extents.x-4, sliderPos);
    };
    popStyle();
  }

  
  boolean mouseDragged()
  {
    if (super.mouseDragged())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-4, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, maximum, minimum));
      };
      return true;
    }
    return false;
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-10, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, maximum, minimum));
      };
      return true;
    }
    return false;
  }
}

class MultiSlider extends Widget
{
  Slider [] sliders;

  MultiSlider(String [] nm, float min, float max, int x, int y, int w, int h, int orientation)
  {
    super(nm[0], x, y, w, h*nm.length);
    sliders = new Slider[nm.length];
    for (int i = 0; i < sliders.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x;
        by = y+i*h;
      }
      else
      {
        bx = x+i*w;
        by = y;
      }
      sliders[i] = new Slider(nm[i], 0, min, max, bx, by, w, h, orientation);
    }
  }

  void set(int i, float v)
  {
    if(i >= 0 && i < sliders.length)
    {
      sliders[i].set(v);
    }
  }
  
  float get(int i)
  {
    if(i >= 0 && i < sliders.length)
    {
      return sliders[i].get();
    }
    else
    {
      return -1;
    }
    
  }

  void display()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      sliders[i].display();
    }
  }

  
  boolean mouseDragged()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseReleased())
      {
        return true;
      }
    }
    return false;
  }
}

public class GlobalMenu {

  public GlobalMenu(int a_width, int c_width, int a_height, int c_height) {
    this.c_width = c_width;
    this.c_height = c_height;
    int button_width = width - a_width - c_width;
    int button_height = c_width;
    int n_vertical = a_height / c_height;
    int scorer_x = (int)(width / 2) - 150;
    int coin_scorer_y = (int)(height / 2) - (int)(2.2 * c_height);
    if (n_vertical <= 10) {
      coin_scorer_y = (int)(height / 2) - (int)(1.2 * c_height);
    }
    int gem_scorer_y = coin_scorer_y + (int)(1.5 * c_height);
    int diamond_scorer_y = gem_scorer_y + (int)(1.5 * c_height);
    int rock_scorer_y = diamond_scorer_y + (int)(1.5 * c_height);
    if (n_vertical <= 10) {
      gem_scorer_y = coin_scorer_y + c_height;
      diamond_scorer_y = gem_scorer_y + c_height;
      rock_scorer_y = diamond_scorer_y + c_height;
    }
    coin_scorer = new Scorer(scorer_x, coin_scorer_y, c_width, c_height, G_COIN_IMAGE);
    gem_scorer = new Scorer(scorer_x, gem_scorer_y, c_width, c_height, G_GEM_IMAGE);
    diamond_scorer = new Scorer(scorer_x, diamond_scorer_y, c_width, c_height, G_DIAMOND_IMAGE);
    rock_scorer = new Scorer(scorer_x, rock_scorer_y, c_width, c_height, G_ROCK_IMAGE);
    coin_scorer.incrementScore(1);
    gem_scorer.incrementScore(1);
    diamond_scorer.incrementScore(1);
    rock_scorer.incrementScore(1);
    
    continue_button = new CoinButton((int)((width - button_width) / 2) - 45, (int)((height) / 2) + 200, button_width + 50, button_height, "Next Level");
    //store_button = new CoinButton((int)((width - button_width) / 2) + 150, (int)((height) / 2) + 200, button_width, button_height, "Store");
    sound_button = new Toggle("", width - 4 * c_width, height - 4 * c_height, 2 * c_width, 2 * c_height);
  }
  
  public void display(int level) {
    background(0);
    stroke(255);
    pushStyle();
    textFont(G_CLOCK_FONT);
    textSize(100);
    fill(183, 154, 0);
    text("Level " + level, (int)(width /2) - 250, 210);
    popStyle(); 
    coin_scorer.drawit();
    gem_scorer.drawit();
    diamond_scorer.drawit();
    rock_scorer.drawit();
    continue_button.drawit();
    //store_button.drawit();
    if (G_SOUND_STATE)
      sound_button.setActiveImage(G_SOUNDON_IMAGE);
    else
      sound_button.setActiveImage(G_SOUNDOFF_IMAGE);
    sound_button.display();
  }
  
  // Getters
  public Scorer getCoinScorer() {
    return coin_scorer;
  }
  public Scorer getGemScorer() {
    return gem_scorer;
  }
  public Scorer getDiamondScorer() {
    return diamond_scorer;
  }
  public Scorer getRockScorer() {
    return rock_scorer;
  }
  public CoinButton getContinueButton() {
    return continue_button;
  }
  public CoinButton getStoreButton() {
    return store_button;
  }
  public Toggle getSoundButton() {
    return sound_button;
  }
  
  private int c_width, c_height;
  
  // Coins, Gems, Diamond
  private int coins, gems, diamonds, rocks;
  
  // Continue Button
  private CoinButton continue_button, store_button;
  private Toggle sound_button;
  
  private Scorer coin_scorer, gem_scorer, diamond_scorer, rock_scorer;
}
public class Menu {
  
  public Menu(int a_width, int c_width, int a_height, int c_height) {
    int button_width = width - a_width - c_width;
    int button_height = c_width;
    start_button = new CoinButton(width / 2 - button_width - cell_width() / 2, height - 4 * button_height, button_width, button_height, "Start");
    tut_button = new CoinButton(width / 2 + cell_width() / 2, height - 4 * button_height, button_width, button_height, "Tutorial");
    //store_button = new CoinButton((int)((width - button_width) / 2) + button_width + 10, (int)((height) / 2) + 205, button_width - 20, button_height - 10, "Store");
    sound_button = new Toggle("", width - 4 * c_width, height - 4 * c_height, 2 * c_width, 2 * c_height);
  }
  
  // getter 
  public CoinButton getStartButton() {
    return start_button;
  }

   public CoinButton getTutButton() {
    return tut_button;
  }

   public CoinButton getStoreButton() {
    return store_button;
  }

  public Toggle getSoundButton() {
    return sound_button;
  }
  
  public void display() {
    background(0);
    stroke(255);
    imageMode(CENTER);
    image(G_LOGO_IMAGE, width/2, height/2 - height/6, height / 3, height / 3);
    pushStyle();
    textSize(cell_height());
    text("Coin Of Life", width/2 - 100, height/2 + cell_height());
    textSize(cell_height() / 2);
    fill(183, 154, 0);
    text("The most addictive coin game ever!", width/2 - 150, height/2 + 2 * cell_height());
    fill(255);
    textSize(cell_height() / 3);
    text("Place coins on board, watch them evolve, earn gems, diamonds and rocks!", width/2 - 200, height/2 + 3 * cell_height());
    popStyle();
    start_button.drawit();
    tut_button.drawit();
    //store_button.drawit();
    if (G_SOUND_STATE)
      sound_button.setActiveImage(G_SOUNDON_IMAGE);
    else
      sound_button.setActiveImage(G_SOUNDOFF_IMAGE);
    sound_button.display();
  }
  
  // Button
  private CoinButton start_button, tut_button, store_button;
  private Toggle sound_button;
}
import java.util.ArrayList;

public class Player {

  // Constants
  final static int INIT = 0;
  final static int PLAYING = 1;
  final static int SIMULATING = 2;
  final static int TIMEOUT = 3;
  final static int FINISHED = 4;
  final static int TUT = 5;
  final static int TUT_PLAYING = 6;
  final static int TUT_READY = 7;
  final static int TUT_SIMULATING = 8;
  final static int TUT_TIMEOUT = 9;
  
  final static int MENU = -1;
  final static int NEXTLEVEL = -2;
  final static int STORE_INIT = -3;

  final static int MAX_TIMER = 90;

  // Constructor
  public Player(int a_width, int c_width, int a_height, int c_height, int max_grid_x, int max_grid_y) {
    this.a_width = a_width;
    this.c_width = c_width;
    this.a_height = a_height;
    this.c_height = c_height;
    this.max_grid_x = max_grid_x;
    this.max_grid_y = max_grid_y;
    this.level = 1;
    int n_vertical = a_height / c_height;

    // Create Board
    board = new Board(level, max_grid_x, max_grid_y);
    
    // Create initial state
    state = MENU;

    // Create timer
    int timer_x = a_width;
    int timer_y = (int)(a_height * 0.9f);
    if (n_vertical <= 10) {
        timer_y = (int)(a_height * 0.95f);
    }
    timer = new Timer(timer_x, timer_y, MAX_TIMER);

    // Create buttons
    int button_x = a_width;
    int play_y = 2 * c_height;
    int undo_y = (int)(c_height * 3.5);
    int reset_y = c_height * 5;
    int button_width = width - a_width - c_width;
    int button_height = c_height;
    if (n_vertical <= 10) {
        undo_y = c_height * 3;
        reset_y = c_height * 4;
    }
    play_button = new CoinButton(button_x, play_y, button_width, button_height, "Play");
    undo_button = new CoinButton(button_x, undo_y, button_width, button_height, "Undo");
    reset_button = new CoinButton(button_x, reset_y, button_width, button_height, "Reset");
    goback_button = new CoinButton(button_x, play_y, button_width, button_height, "Main Menu");

    // Create Scorers for multiple entities
    int scorer_x = a_width;
    int coin_scorer_y = (int)(c_height * 7);
    if (n_vertical <= 10) {
        coin_scorer_y = c_height * 5;
    }
    int gem_scorer_y = coin_scorer_y + c_height;
    int diamond_scorer_y = gem_scorer_y + c_height;
    int rock_scorer_y = diamond_scorer_y + c_height;
    coin_scorer = new Scorer(scorer_x, coin_scorer_y, c_width, c_height, G_COIN_IMAGE);
    gem_scorer = new Scorer(scorer_x, gem_scorer_y, c_width, c_height, G_GEM_IMAGE);
    diamond_scorer = new Scorer(scorer_x, diamond_scorer_y, c_width, c_height, G_DIAMOND_IMAGE);
    rock_scorer = new Scorer(scorer_x, rock_scorer_y, c_width, c_height, G_ROCK_IMAGE);
    
    // Create Menu screen
    this.menu = new Menu(a_width, c_width, a_height, c_height);
    
    // Create the global menu screen
    this.global_menu = new GlobalMenu(a_width, c_width, a_height, c_height);
    
    // Create Store drawer
    store_drawer = new StoreDrawer(a_width, c_width, a_height, c_height);
    
    init();
  }

  // Init method to init things after next level pressed
  public void init() {
    board.init(this.level);
    timer.init(MAX_TIMER);
    coin_scorer.init();
    gem_scorer.init();
    diamond_scorer.init();
    rock_scorer.init();
    L_OK_TO_PLAY = true;  
  }
  // Getters
  public int get_a_width() { 
    return a_width;
  }
  public int get_c_width() { 
    return c_width;
  }
  public int get_a_height() { 
    return a_height;
  }
  public int get_c_height() { 
    return c_height;
  }
  public boolean[][] getAlive() { 
    return board.getAlive();
  }
  public boolean[][] getEverAlive() { 
    return board.getEverAlive();
  }
  public boolean[][] getGemPositions() {
    return board.getGemPositions();
  }
  public boolean[][] getDiamondPositions() {
    return board.getDiamondPositions();
  }
  public boolean[][] getRockPositions() {
    return board.getRockPositions();
  }
  public boolean[][] getHitPositions() {
    return board.getHitPositions();
  }
  public CoinButton get_play_button() { 
    return play_button;
  }
  public CoinButton get_undo_button() { 
    return undo_button;
  }
  public CoinButton get_reset_button() { 
    return reset_button;
  }
  public CoinButton get_goback_button() { 
    return goback_button;
  }
  public Timer getTimer() { 
    return timer;
  }
  public Scorer getCoinScorer() { 
    return coin_scorer;
  }
  public Scorer getGemScorer() { 
    return gem_scorer;
  }
  public Scorer getDiamondScorer() { 
    return diamond_scorer;
  }
  public Scorer getRockScorer() { 
    return rock_scorer;
  }
  public Menu getMenu() {
    return menu;
  }
  public GlobalMenu getGlobalMenu() {
    return global_menu;
  }
  public int getLevel() {
    return level;
  }
  public int getState() {
    return state;
  }
  public boolean get_tut_wrong() {
    return TUT_WRONG;
  }
  public StoreDrawer getStoreDrawer() {
    return store_drawer;
  }
  
  //Setters
  public void setState(int st) {
    this.state = st;
  }
  
  // Place a coin on cell
  public void placeCoin() {
    if (state != PLAYING && state != TUT_PLAYING) return;
    board.placeCoin();
  }

  // Responds to undo press by user
  public void undo() {
    if (state != PLAYING) return;
    board.undo();
  }

  // Responds to reset pressed by user
  public void reset() {
    if (state != PLAYING) return;
    board.reset();
  }

  // Check if all coins filled
  private boolean allTutCoinsFilled() {
      boolean[][] tempAlive = getAlive();
      int my_count = 0;
      for (int i = 0; i < tempAlive.length; i++) 
        for (int j = 0; j < tempAlive[i].length; j++)
         if (tempAlive[i][j])
            my_count++;
      return my_count == TUT_POS_X.length;
  }
  
  // Simulate the board
  public void simulate() {
    if (state != SIMULATING && state != TUT_SIMULATING) return;
    if (G_SOUND_STATE && L_OK_TO_PLAY) {
      G_PLAY_PLAYER.play();
      L_OK_TO_PLAY = false;
    }
    
    // Simulate the board
    int[] score_increments = board.simulate();
    coin_scorer.incrementMaxScore(score_increments[0]);
    gem_scorer.incrementMaxScore(score_increments[1]);
    diamond_scorer.incrementMaxScore(score_increments[2]);
    rock_scorer.incrementMaxScore(score_increments[3]);
    
    // Advance time for timer, check if it has timed out and set the state
    if (timer.isTimeout()) {
      if (state == SIMULATING) 
        state = TIMEOUT;
      else
        state = TUT_TIMEOUT;
    }
    else
      timer.advanceit();
  }

  // All interactions with mouse pressed
  public void mouseReleased() {
    if (state == MENU && menu.getStartButton().mouseReleased()) {
      state = INIT;
    }

    else if (state == MENU && menu.getTutButton().mouseReleased()) {
      state = TUT;
      init();
    }
    else if ( (state == TUT || state == TUT_PLAYING) && mouseX >= c_width && mouseX <= a_width - c_width && mouseY >= c_height && mouseY <= a_height - c_height) {
      state = TUT_PLAYING;
      boolean flag = false;
      int my_X = (int) (mouseX /  c_width);
      int my_Y = (int) (mouseY / c_height);
      // Check if inside Red Square
      for (int i = 0; i < TUT_POS_X.length; i++) {
        if (TUT_POS_X[i] == my_X && TUT_POS_Y[i] == my_Y) {
          flag = true;
          break;
        }
      }
      if (flag) {
        placeCoin();
        TUT_WRONG = false;
      }
      else
        TUT_WRONG = true;
      if (allTutCoinsFilled())
         state = TUT_READY;     
    }
    else if ((state == TUT || state == TUT_PLAYING) && play_button.mouseReleased()) {
      TUT_WRONG = true;
    }
    else if (state == TUT_READY && play_button.mouseReleased()) {
      state = TUT_SIMULATING;
    }
    else if (state == TUT_TIMEOUT && goback_button.mouseReleased()) {
      state = MENU;
      init();
    }
    /*else if ((state == MENU && menu.getStoreButton().mouseReleased()) || (state == NEXTLEVEL && global_menu.getStoreButton().mouseReleased())) {
      state = STORE_INIT;
    }*/
    else if (state == STORE_INIT && store_drawer.getBackButton().mouseReleased()) {
      state = NEXTLEVEL;
      G_TIMER = 0;
    }   
    else if (state == MENU && menu.getSoundButton().mouseReleased()) {
      G_SOUND_STATE = !G_SOUND_STATE;
    }
    else if (state == NEXTLEVEL && global_menu.getContinueButton().mouseReleased()) {
      state = INIT;
      // Increment the level
      this.level = this.level + 1;
      init();
    }
    
    else if (state == NEXTLEVEL && global_menu.getSoundButton().mouseReleased()) {
      G_SOUND_STATE = !G_SOUND_STATE;
    }
    
    else if ((state == INIT || state == PLAYING) && play_button.mouseReleased()) {
      state = SIMULATING;
    }
    else if ((state == INIT || state == PLAYING) && undo_button.mouseReleased()) {
      state = PLAYING;
      undo();
    }
    else if ((state == INIT || state == PLAYING) && reset_button.mouseReleased()) {
      state = PLAYING;
      reset();
    }
    else if ((state == INIT || state == PLAYING) && mouseX >= c_width && mouseX <= a_width - c_width && mouseY >= c_height && mouseY <= a_height) {
      state = PLAYING;
      placeCoin();
    }
  }
  
  // Advance scorer after timeout
  public void advanceScorers() {
    G_PLAY_PLAYER.stop();
    G_TIMER = 0;
    
    while (!coin_scorer.reachedMaxScore()) 
      coin_scorer.incrementScore(1);
    while (!gem_scorer.reachedMaxScore()) 
      gem_scorer.incrementScore(1);
    while (!diamond_scorer.reachedMaxScore()) 
      diamond_scorer.incrementScore(1);
    while (!rock_scorer.reachedMaxScore()) 
      rock_scorer.incrementScore(1);
      
    // Set globalMenu
    global_menu.getCoinScorer().incrementScore(coin_scorer.getMaxScore());
    global_menu.getGemScorer().incrementScore(gem_scorer.getMaxScore());
    global_menu.getDiamondScorer().incrementScore(diamond_scorer.getMaxScore());
    global_menu.getRockScorer().incrementScore(rock_scorer.getMaxScore());
    
    // Set the state
    state = FINISHED;
  }
  
  // Busy wait for 100 units after FINISHED state
  public void waitForNextLevel() {
    if (G_TIMER == 10) {
      if (G_SOUND_STATE) {
        G_COIN_PLAYER.cue(0);
        G_COIN_PLAYER.play();
      }
      G_TIMER = G_TIMER + 1;
    }
    else if (G_TIMER >= 80) {
      state = NEXTLEVEL;
      G_TIMER = 0;
      G_COIN_PLAYER.stop();
    }  
    else {
      G_TIMER = G_TIMER + 1;
    }
  }
  
  public void mousePressed() {
    if (state != TUT_TIMEOUT && state!= STORE_INIT) {
      play_button.mousePressed(); 
      undo_button.mousePressed();
      reset_button.mousePressed();
    }
    if (state == MENU) {
      menu.getStartButton().mousePressed();
      menu.getTutButton().mousePressed();
      //menu.getStoreButton().mousePressed();
    }
    if (state == NEXTLEVEL)
      global_menu.getContinueButton().mousePressed();
    if (state == TUT_TIMEOUT)
      goback_button.mousePressed();
    if (state == STORE_INIT) {
      store_drawer.getBackButton().mousePressed();
      store_drawer.coin_1000.mousePressed();
      store_drawer.coin_10000.mousePressed();
      store_drawer.gem_100.mousePressed();
      store_drawer.gem_1000.mousePressed();
      store_drawer.diamond_100.mousePressed();
      store_drawer.diamond_1000.mousePressed();
      store_drawer.rock_100.mousePressed();
      store_drawer.rock_1000.mousePressed(); 
    }
  }
  // Private
  // Dimensions of grid
  private int max_grid_x, max_grid_y;
  // Dimensions of arena
  private int a_width, a_height;
  // Dimensions of cell
  private int c_width, c_height;

  // Level
  private int level;
  
  // Maintain the state
  private int state;
 
  // Board
  private Board board;
  
  // Buttons
  private CoinButton play_button, undo_button, reset_button, goback_button;

  // Timer to check if game has ended
  private Timer timer;
     
  // Scorer
  private Scorer coin_scorer, gem_scorer, diamond_scorer, rock_scorer;

  // Menu
  private Menu menu;

  // global menu to display between levels
  private GlobalMenu global_menu;
  
  // Ok to play flag
  private boolean L_OK_TO_PLAY;
  
  // Tutorial wrong flag
  private boolean TUT_WRONG;
  
  // StoreDrawer
  private StoreDrawer store_drawer;
   
}

public class Scorer {

  public Scorer(int x, int y, int wd, int ht, PImage img) {
    this.x = x;
    this.y = y;
    this.wd = wd;
    this.ht = ht;
    init();
    this.m_image = img;
  }

  public void init() {
    this.score = -1;
    this.max_score = 0;
  }
  
  // Getter
  public int getScore() { 
    return score;
  }
  
  public int getMaxScore() { 
    return max_score;
  }
  
  public void incrementScore(int i) {
    this.score = this.score + i;
  }

  public void incrementMaxScore(int i) {
    this.max_score = this.max_score + i;
  }
 
  public boolean reachedMaxScore() {
    return (this.score >= this.max_score);
  }

  public void drawit() {
    fill(0);
    stroke(0);
    int s = score;
    if (s < 0)
      return;
    int[] digits = new int[0];
    while (s >= 0) {
      digits = append(digits, s % 10);
      s = (int)(s / 10);
      if (s == 0)
        break;
    }
    
    image(this.m_image, x, y, this.wd, this.ht);
    for (int j = digits.length - 1; j >= 0; j--) {
       image(G_DIGIT_IMAGES[digits[j]], x + (digits.length - j) * wd, y, wd, ht);
    }
  }

  // Private
  private int x;
  private int y;
  private int wd;
  private int ht;
  private int score;
  private int max_score;
  private PImage m_image;
}
public class StoreDrawer {
  
  public StoreDrawer(int a_width, int c_width, int a_height, int c_height) {
   
    int button_width = width - a_width - c_width;
    int button_height = c_height;
    int left_x = 300;
    int right_x = left_x + (int)(2.5 * button_width);
    int button_top = 100;
    
    coin_1000 = new CoinButton(left_x, button_top, button_width, button_height, "$1.99"); 
    coin_10000 = new CoinButton(right_x, button_top, button_width, button_height, "$15.99"); 
    gem_100 = new CoinButton(left_x, button_top + 2 * button_height, button_width, button_height, "$2.99"); 
    gem_1000 = new CoinButton(right_x, button_top + 2 * button_height, button_width, button_height, "$25.99"); 
    diamond_100 = new CoinButton(left_x, button_top + 4 * button_height, button_width, button_height, "$3.99"); 
    diamond_1000 = new CoinButton(right_x, button_top + 4 * button_height, button_width, button_height, "$35.99"); 
    rock_100 = new CoinButton(left_x, button_top + 6 * button_height, button_width, button_height, "$3.99"); 
    rock_1000 = new CoinButton(right_x, button_top + 6 * button_height, button_width, button_height, "$35.99");
    back_button = new CoinButton(width / 2 - button_width, button_top + 8 * button_height, button_width * 2, button_height * 2, "Back");
  }
 
  // drawit
  public void drawit(int a_width, int c_width, int a_height, int c_height) {
    // Setting up background and colors
    background(0);
    stroke(255);
    
    int top_y = coin_1000.getY();
    int left_x = coin_1000.getX();
    int button_width = coin_1000.getWidth();
    int button_height = coin_1000.getHeight();
    
    int left_image_x = 100;
    int left_text_x = 170;
    int right_image_x = left_x + (int)(1.5 * button_width);
    int right_text_x = left_x + (int)(1.8 * button_width);
    
    pushStyle();
    
    // Images
    imageMode(CORNER);
    image(G_COIN_IMAGE, left_image_x, top_y, 50, 50);
    image(G_COIN_IMAGE, right_image_x, top_y, 50, 50);
    image(G_GEM_IMAGE, left_image_x, top_y + 2 * button_height, 50, 50);
    image(G_GEM_IMAGE, right_image_x, top_y + 2 * button_height, 50, 50);
    image(G_DIAMOND_IMAGE, left_image_x, top_y + 4 * button_height, 50, 50);
    image(G_DIAMOND_IMAGE, right_image_x, top_y + 4 * button_height, 50, 50);
    image(G_ROCK_IMAGE, left_image_x, top_y + 6 * button_height, 50, 50);
    image(G_ROCK_IMAGE, right_image_x, top_y + 6 * button_height, 50, 50);
    
    int top_text_y = top_y + 35;
    textSize(30);
    fill(255);
    text("X 1000", left_text_x, top_text_y);
    text("X 10000", right_text_x, top_text_y);
    text("X 100", left_text_x, top_text_y + 2 * button_height);
    text("X 1000", right_text_x, top_text_y + 2 * button_height);
    text("X 100", left_text_x, top_text_y + 4 * button_height);
    text("X 1000", right_text_x, top_text_y + 4 * button_height);
    text("X 100", left_text_x, top_text_y + 6 * button_height);
    text("X 1000", right_text_x, top_text_y + 6 * button_height);
    
    popStyle();
    
    pushStyle();
    
    fill(0);
    coin_1000.drawit();
    coin_10000.drawit();
    gem_100.drawit();
    gem_1000.drawit();
    diamond_100.drawit();
    diamond_1000.drawit();
    rock_100.drawit();
    rock_1000.drawit();
    back_button.drawit();
    
    popStyle();
  }
  
  // Getter
  CoinButton getBackButton() {
    return back_button;
  }
  
  public CoinButton coin_1000, coin_10000, gem_100, gem_1000, diamond_100, diamond_1000, rock_100, rock_1000;
  private CoinButton back_button;
}

public class Timer {
  // Constructor
  public Timer(int x, int y, int max_value) {
    this.x = x;
    this.y = y;
    init(max_value);
  }

  public void init(int max_value) {
    this.max_value = max_value;
    this.curr_value = 0;
  }
  
  //drawit
  public void drawit(int a_width, int c_width, int a_height, int c_height) {
    pushStyle();
    fill(197,179,88);
    textFont(G_CLOCK_FONT, 30);    
    text("Time", x, y);
    
    fill(153,101,21);
    rect(x, y + (int)(c_height/2), (int)( (width - a_width - c_width) * (max_value - curr_value) / max_value), (int)(c_height/2));
    popStyle();
  }
  
  // advance timer
  public void advanceit() {
    curr_value++;
  }
  
  // check if it is timed out
  public boolean isTimeout() {
    return (curr_value >= max_value);
  }
  
  //private
  private int x, y;
  private int max_value, curr_value;
}

public class TutDrawer {
  
  public TutDrawer(Player p) {
    player = p;
  }
  
  // drawit
  public void drawit(int a_width, int c_width, int a_height, int c_height) {
    // Setting up background and colors
    background(0);
    stroke(255);
    
    int n_horizontal = (int)(a_width / c_width);
    int n_vertical = (int)(a_height / c_height);

    // Draw all the cells
    for (int i = 1; i < n_horizontal; i++) {
      line(i * c_width, 2 * c_height, i * c_width, n_vertical * c_height);
    }
    for (int i = 2; i <= n_vertical; i++) {
      line(c_width, i * c_height, (n_horizontal - 1) * c_width, i * c_height);
    }
    
    // Red Squares
    pushStyle();
    fill(104, 0, 0);
    for (int i = 0; i < TUT_POS_X.length; i++) 
      rect(TUT_POS_X[i] * c_width, TUT_POS_Y[i] * c_height, c_width, c_height);
    popStyle(); 
    
    // Draw coins in cells
    boolean[][] alive = player.getAlive();
    boolean[][] ever_alive = player.getEverAlive();
    for (int i = 0; i < alive.length; i++) {
      for (int j = 2; j < alive[i].length; j++) {
        if (ever_alive[i][j]) {
          pushStyle();
          fill(75, 75, 75);
          rect(i * c_width, j * c_height, c_width, c_height);
          popStyle();
        }
        if (alive[i][j]) {
          imageMode(CORNER);
          image(G_COIN_IMAGE, i * c_width, j * c_height, c_width, c_height);
        }
      }
    }
    
      // Draw the buttons
    if (player.getState() == Player.TUT_TIMEOUT)
      player.get_goback_button().drawit();
    else {
      player.get_play_button().drawit();
      if (player.get_tut_wrong()) {
        pushStyle();
        textSize(24);
        fill(200, 0, 0);
        text("Tap all and only red squares!", a_width - (int)(1.1 * c_width), 5 * c_height);
        popStyle(); 
      }
    }

    // Draw the timer
    player.getTimer().drawit(a_width, c_width, a_height, c_height);
   
    // Draw instructions
    pushStyle();
    fill(255, 255, 255);
    
    if (player.getState() == Player.TUT_SIMULATING || player.getState() == Player.TUT_READY) {
      textSize(45);
      text("Hit Play!", a_width + c_width, height / 2);
    }
    else if (player.getState() == Player.TUT_TIMEOUT) {
      textSize(20);
      text("Try placing different", a_width, height / 2);
      text("coins on board and", a_width, height / 2 + 30);
      text("collide with gems/diamonds", a_width, height / 2 + 60);
    }
    else {
      textSize(30);
      text("Tap the Red Squares", a_width - c_width, height / 2);
    }
    popStyle();
  }
  
  private Player player;
}
int arena_width() {
  return (int)(width * 0.76);
}

int arena_height() {
  return height;
}

int cell_width() {
  if (height <= 240)
    return 20;
  if (height <= 480)
    return 40;
  return 40;
}

int cell_height() {
  //return (int)(cell_width() * float(arena_height()) / float(arena_width()));
  return cell_width();
}

int max_grid_X() {
  return (int)(arena_width() / cell_width()) - 2;
}

int max_grid_Y() {
  return (int)(arena_height() / cell_height()) - 1;
}

int min_grid_X() {
  return 1;
}

int min_grid_Y() {
  return 1;
}

final int[] TUT_POS_X = {7, 7, 8, 9, 9, 9};
final int[] TUT_POS_Y = {7, 6, 6, 6, 7, 8};
  


