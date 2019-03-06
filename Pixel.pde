public class Pixel {
  private Integer[] point;
  private color c;
  
  public Pixel(int x, int y, color c) {
    this.point = new Integer[]{x,y};
    this.c = c;
  }
  
  public Integer[] coords() {
    return point;
  }
  
  public color getColor() {
    return c;
  }
}
