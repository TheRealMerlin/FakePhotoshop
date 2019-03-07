public class Button {
  private String name;
  private float x, y, width, height, fontSize;
  private int back_color;
  private int text_color;
  private boolean toggable;
  boolean on;

  public Button(float p0, float p1, float width, float height, String name, boolean toggable) {
    this.x = p0;
    this.y = p1;
    this.width = width;
    this.height = height;
    this.name = name;
    this.fontSize = 12;
    this.back_color = 255;
    this.text_color = 0;
    this.toggable = toggable;
    this.on = false;
  }
  
  public Button(float p0, float p1, float width, float height, String name, boolean toggable, int fontSize) {
    this(p0, p1, width, height, name, toggable);
    this.fontSize = fontSize;
  }

  public void draw() {
    fill(back_color);
    stroke(back_color);
    rect(x, y, width, height);
    fill(text_color);
    textFont(createFont("Arial", fontSize));
    textAlign(CENTER, CENTER);
    text(name, x, y, width, height);
  }
  
  public void update() {
    if(!toggable) {
      if(isOver()){
        back_color = #7DC8F0;
      }else {
        back_color = 255;
      }
    }else {
      if(on) {
        back_color = #7DC8F0;
      }else {
        back_color = 255;
      }
    }
  }

  public boolean isOver() {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
      return true;
    }
    return false;
  }
}
