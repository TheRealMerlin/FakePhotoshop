import java.io.File;
import java.util.Map;
import java.util.Set;

PImage image, temp, output, colorChart;
HashMap<String, Button> buttons;
ArrayList<Layer> layers;
ColorPicker cP;
color primaryColor, secondaryColor;
Cursor cState;
int penSize, layerSelected, startX, startY, endX, endY;
boolean updateImage, removeImage, updateLayers;
Layer current;

enum Cursor {
  MOVING, DRAWING;
}

void setup() {
  surface.setSize(1280, 720);
  frameRate(60);
  colorChart = loadImage("spectrum_chart.jpg");
  primaryColor = #FFFFFF;
  secondaryColor = #FFFFFF;
  penSize = 12;
  cState = Cursor.MOVING;
  buttons = new HashMap<String, Button>();
  buttons.put("bOpen", new Button(0, 0, 35, 18, "Open", false));
  buttons.put("bSave", new Button(36, 0, 35, 18, "Save", false));
  buttons.put("bClose", new Button(72, 0, 35, 18, "Close", false));
  buttons.put("bColor", new Button(108, 0, 35, 18, "Color", false));
  buttons.put("bPaint", new Button(144, 0, 35, 18, "Paint", true));
  buttons.put("bMove", new Button(180, 0, 35, 18, "Move", true));
  buttons.get("bMove").on = true;
  buttons.put("bReset", new Button(216, 0, 35, 18, "Reset", false));
  buttons.put("bPenInc", new Button(width-175, 95, 35, 15, "+", false));
  buttons.put("bPenDec", new Button(width-130, 95, 35, 15, "-", false));
  buttons.put("bWaterColor", new Button(width-270, 200, 250, 30, "WaterColor", false, 25));
  background(#777777);
  layers = new ArrayList<Layer>();
  layerSelected = 0;
  updateImage = false;
  removeImage = true;
  updateLayers = false;
}

void draw() {
  if(updateImage || removeImage) {
    reset();
  }
  createToolbar();
  createRightToolbar();
  updateAll();
}

void reset() {
  layers = new ArrayList<Layer>();
  color[] background = new color[(width-300)*(height-20)];
  for(int i = 0; i < background.length; i++) {
    background[i] = #777777;
  }
  layers.add(new Layer(background, width-300, height-20));
  if(updateImage) {
    if(temp != null) {
      temp.resize(width-300, height-20);
      image(temp, (width-300)/2-image.width/2, (height+20)/2-image.height/2);
      temp.loadPixels();
      layers.add(new Layer(temp.pixels, width-300, height-20));
      updateImage = false;
      updateLayers = true;
    }else {
      removeImage = true;
      updateImage = false;
    }
  }
  if(removeImage) {
    noStroke();
    fill(#777777);
    rect(0, 20, width-300, height-20);
    removeImage = false;
  }
}

void createToolbar() {
  noStroke();
  fill(255);
  rect(0,0,width,19);
  stroke(0);
  line(0, 19, width, 19);
}

void createRightToolbar() {
  noStroke();
  fill(138);
  rect(width-299, 20, 299, height-20);
  stroke(0);
  line(width-300, 20, width-300, height);
  
  fill(secondaryColor);
  rect(width-250, 70, 50, 50);
  fill(primaryColor);
  rect(width-275, 45, 50, 50);
  
  noStroke();
  fill(255);
  rect(width-175, 70, 80, 15);
  textAlign(CENTER, CENTER);
  textSize(12);
  fill(0);
  text("Pen Size: "+penSize, width-175, 68, 80, 15);
}

void updateAll() {
  for(Button button : buttons.values()) {
    button.update();
    button.draw();
  }
  if(updateLayers) {
    updateLayers();
  }
}

void updateLayers() {
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  for(Layer l : layers) {
    for(Pixel p : l.pixels) {
      if(p.coords()[0] >= 0 && p.coords()[0] < temp.width && p.coords()[1] >= 0 && p.coords()[1] < temp.height) {
        temp.pixels[p.coords()[1]*temp.width+p.coords()[0]] = p.getColor();
        temp.updatePixels();
      }
    }
  }
  image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
  updateLayers = false;
}

void mousePressed() {
  if(cState == Cursor.DRAWING) {
    current = new Layer();
  }
  if(mouseY <= 18 || mouseX >= width-300) {
    Set<Map.Entry<String, Button>> entries = buttons.entrySet();
    for(Map.Entry<String, Button> entry : entries) {
      if(entry.getValue().isOver()) {
        if(entry.getKey().equals("bOpen")) {
          selectInput("Select the image:", "inputSelected");
        }else if(entry.getKey().equals("bSave")) {
          output = get(0, 20, width-300, height-20);
          selectOutput("Save file as:", "outputSelected");
        }else if(entry.getKey().equals("bClose")) {
          temp = null;
          removeImage = true;
        }else if(entry.getKey().equals("bColor")) {
          cP = new ColorPicker();
        }else if(entry.getKey().equals("bPaint")) {
          cState = Cursor.DRAWING;
          entry.getValue().on = true;
          buttons.get("bMove").on = false;
        }else if(entry.getKey().equals("bMove")) {
          cState = Cursor.MOVING;
          entry.getValue().on = true;
          buttons.get("bPaint").on = false;
        }else if(entry.getKey().equals("bReset")) {
          temp = image;
          updateImage = true;
        }else if(entry.getKey().equals("bPenInc")) {
          penSize = penSize<50?penSize+1:penSize;
        }else if(entry.getKey().equals("bPenDec")) {
          penSize = penSize>1?penSize-1:penSize;
        }else if(entry.getKey().equals("bWaterColor")) {
          
        }
      }
    }
  }else {
    if(cState == Cursor.MOVING) {
      for(int i = layers.size()-1; i >= 0; i--) {
        println(i + " " + layers.get(i).onLayer());
        if(layers.get(i).onLayer()) {
          layerSelected = i;
          break;
        }
      }
      startX = mouseX;
      startY = mouseY;
    }
  }
}

void mouseDragged() {
  if(cState == Cursor.DRAWING) {
    if(mouseButton == LEFT) {
      fill(primaryColor);
      stroke(primaryColor);
      circle(mouseX, mouseY, penSize);
      for(int x = 0; x <= penSize; x++) {
        for(int y = 0; y <= penSize; y++) {
          int dx1 = mouseX + x;
          int dy1 = mouseY + y;
          int dx2 = mouseX - x;
          int dy2 = mouseY - y;
          if(dx1 >= 0 && dx1 <= width-300 && dy1 >= 20 && dy1 <= height) {
            double distance = Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
            if(distance <= penSize) {
              current.add(new Pixel(dx1, dy1, primaryColor));
            }
          }
          if(dx2 >= 0 && dx2 <= width-300 && dy2 >= 20 && dy2 <= height) {
            double distance = Math.sqrt(Math.pow(-x,2)+Math.pow(-y,2));
            if(distance <= penSize) {
              current.add(new Pixel(dx2, dy2, primaryColor));
            }
          }
        }
      }
    }else if(mouseButton == RIGHT) {
      fill(secondaryColor);
      stroke(secondaryColor);
      circle(mouseX, mouseY, penSize);
      for(int x = 0; x <= penSize; x++) {
        for(int y = 0; y <= penSize; y++) {
          int dx1 = mouseX + x;
          int dy1 = mouseY + y;
          int dx2 = mouseX - x;
          int dy2 = mouseY - y;
          if(dx1 >= 0 && dx1 <= width-300 && dy1 >= 20 && dy1 <= height) {
            double distance = Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
            if(distance <= penSize) {
              current.add(new Pixel(dx1, dy1, secondaryColor));
            }
          }
          if(dx2 >= 0 && dx2 <= width-300 && dy2 >= 20 && dy2 <= height) {
            double distance = Math.sqrt(Math.pow(-x,2)+Math.pow(-y,2));
            if(distance <= penSize) {
              current.add(new Pixel(dx2, dy2, secondaryColor));
            }
          }
        }
      }
    }
  }
}

void mouseReleased() {
  if(cState == Cursor.DRAWING) {
    if(current != null && current.pixels.size() != 0) {
      layers.add(current);
    }
  }else if(cState == Cursor.MOVING) {
    if(!(mouseY <= 18 || mouseX >= width-300) && layerSelected > 0) {
      endX = mouseX;
      endY = mouseY;
      println("dx: " + (endX-startX) + " dy: " + (endY-startY));
      layers.get(layerSelected).translate(endX-startX, endY-startY);
      updateLayers = true;
    }
  }
}

void inputSelected(File selection) {
  if (selection == null) {
    println("File path not found.");
  } else {
    image = loadImage(selection.getAbsolutePath());
    temp = image;
    updateImage = true;
  }
}
  
void outputSelected(File selection) {
  if (selection == null) {
    println("File path not found.");
  } else {
    output.save(selection.getAbsolutePath());
  }
}


public class ColorPicker extends PApplet {
  public ColorPicker() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }
  
  public void setup() {
    surface.setSize(colorChart.width, colorChart.height);
  }
  
  public void draw() {
    image(colorChart, 0, 0);
  }
  
  public void mousePressed() {
    loadPixels();
    if(mouseButton == LEFT) {
      primaryColor = pixels[mouseY*width+mouseX];
    }else if(mouseButton == RIGHT) {
      secondaryColor = pixels[mouseY*width+mouseX];
    }
  }
  
  public void exit() {
    dispose();
    cP = null;
  }
}
