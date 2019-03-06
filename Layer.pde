public class Layer {
  ArrayList<Pixel> pixels;
  
  public Layer() {
    pixels = new ArrayList<Pixel>();
  }
  
  public Layer(color[] pixels, int width, int height) {
    this.pixels = new ArrayList<Pixel>();
    for(int i = 0; i < height; i++) {
      for(int j = 0; j < width; j++) {
        this.add(new Pixel(j, i, pixels[i*width+j]));
      }
    }
  }
  
  public void add(Pixel p) {
    pixels.add(p);
  }
  
  public boolean onLayer() {
    for(Pixel p : pixels) {
      if(p.coords()[0] == mouseX && p.coords()[1] == mouseY) {
        return true;
      }
    }
    return false;
  }
  
  public void translate(int dx, int dy) {
    for(int i = 0; i < pixels.size(); i++) {
      Pixel p = pixels.get(i);
      pixels.set(i, new Pixel(p.coords()[0]+dx, p.coords()[1]+dy, p.getColor()));
    }
  }
}
