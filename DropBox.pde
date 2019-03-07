/* 
This was a failed effort, please disrgard! :)
*/
public class DropBox {
  private int i, j, bWidth, bHeight;
  private String name;
  private ArrayList<Button> buttons;
  
  public DropBox(int i, int j, int bWidth, int bHeight, String name) {
    this.i = i;
    this.j = j;
    buttons = new ArrayList<Button>();
    buttons.add(new Button(i, j, bWidth, bHeight, name, false));
  }
  
  public void add(Button b) {
    buttons.add(b);
  }
  
  public void set(int index, Button b) {
    buttons.set(index, b);
  }
}
