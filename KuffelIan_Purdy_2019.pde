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
boolean updateImage, removeImage, updateLayers, updateState;
Layer current;

enum Cursor {
  MOVING, DRAWING, FILLING, CROPPING;
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
  buttons.put("bReset", new Button(108, 0, 35, 18, "Reset", false));
  buttons.put("bColor", new Button(width-75, 58, 50, 50, "Change Color", false));
  buttons.put("bPenInc", new Button(width-175, 95, 35, 15, "+", false));
  buttons.put("bPenDec", new Button(width-130, 95, 35, 15, "-", false));
  buttons.put("bMove", new Button(width-275, 150, 80, 20, "Move", true));
  buttons.get("bMove").on = true;
  buttons.put("bPaint", new Button(width-190, 150, 80, 20, "Paint", true));
  buttons.put("bFill", new Button(width-105, 150, 80, 20, "Fill", true));
  buttons.put("bCrop", new Button(width-190, 175, 80, 20, "Crop", true));
  buttons.put("bWaterColor", new Button(width-275, 225, 250, 30, "Water Color", false, 25));
  buttons.put("bMosaic", new Button(width-275, 265, 250, 30, "Mosaic", false, 25));
  buttons.put("bBlur", new Button(width-275, 305, 250, 30, "Blur", false, 25));
  background(#777777);
  layers = new ArrayList<Layer>();
  layerSelected = 0;
  updateImage = false;
  removeImage = true;
  updateLayers = false;
  updateState = false;
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
      image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
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
  if(updateState) {
    buttons.get("bMove").on = false;
    buttons.get("bPaint").on = false;
    buttons.get("bFill").on = false;
    buttons.get("bCrop").on = false;
    switch(cState) {
      case MOVING: buttons.get("bMove").on = true; break;
      case DRAWING: buttons.get("bPaint").on = true; break;
      case FILLING: buttons.get("bFill").on = true; break;
      case CROPPING: buttons.get("bCrop").on = true; break;
    }
    updateState = false;
  }
}

void updateLayers() {
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  for(Layer l : layers) {
    for(Pixel p : l.pixels) {
      if(p.coords()[0] >= 0 && p.coords()[0] < temp.width && p.coords()[1] >= 0 && p.coords()[1] < temp.height) {
        temp.pixels[p.coords()[1]*temp.width+p.coords()[0]] = p.getColor();
      }
    }
  }
  temp.updatePixels();
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
        }else if(entry.getKey().equals("bReset")) {
          temp = image;
          updateImage = true;
        }else if(entry.getKey().equals("bColor")) {
          cP = new ColorPicker();
        }else if(entry.getKey().equals("bPenInc")) {
          penSize = penSize<50?penSize+1:penSize;
        }else if(entry.getKey().equals("bPenDec")) {
          penSize = penSize>1?penSize-1:penSize;
        }else if(entry.getKey().equals("bMove")) {
          cState = Cursor.MOVING;
          updateState = true;
        }else if(entry.getKey().equals("bPaint")) {
          cState = Cursor.DRAWING;
          updateState = true;
        }else if(entry.getKey().equals("bFill")) {
          cState = Cursor.FILLING;
          updateState = true;
        }else if(entry.getKey().equals("bCrop")) {
          cState = Cursor.CROPPING;
          updateState = true;
        }else if(entry.getKey().equals("bWaterColor")) {
          waterColor();
        }else if(entry.getKey().equals("bMosaic")) {
          mosaic();
        }else if(entry.getKey().equals("bBlur")) {
          blur();
        }
      }
    }
  }else {
    if(cState == Cursor.MOVING) {
      for(int i = layers.size()-1; i >= 0; i--) {
        if(layers.get(i).onLayer()) {
          layerSelected = i;
          break;
        }
      }
      startX = mouseX;
      startY = mouseY;
    }else if(cState == Cursor.FILLING) {
      if(mouseButton == LEFT) {
        temp = get(0,20,width-300, height-20);
        temp.loadPixels();
        color startColor = temp.pixels[(mouseY-20)*temp.width+mouseX];
        ArrayList<Pixel> test = new ArrayList<Pixel>();
        for(int i = 0; i < temp.height; i++) {
          for(int j = 0; j < temp.width; j++) {
            color c = temp.pixels[i*temp.width+j];
            if(c == startColor) {
              test.add(new Pixel(j, i, startColor));
            }
          }
        }
        for(Pixel p : test) {
          temp.pixels[p.coords()[1]*temp.width+p.coords()[0]] = primaryColor;
        }
        temp.updatePixels();
        reset();
        image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
        layers.add(new Layer(temp.pixels, temp.width, temp.height, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2));
      }else if(mouseButton == RIGHT) {
        temp = get(0,20,width-300, height-20);
        temp.loadPixels();
        color startColor = temp.pixels[(mouseY-20)*temp.width+mouseX];
        ArrayList<Pixel> test = new ArrayList<Pixel>();
        for(int i = 0; i < temp.height; i++) {
          for(int j = 0; j < temp.width; j++) {
            color c = temp.pixels[i*temp.width+j];
            if(c == startColor) {
              test.add(new Pixel(j, i, startColor));
            }
          }
        }
        for(Pixel p : test) {
          temp.pixels[p.coords()[1]*temp.width+p.coords()[0]] = secondaryColor;
        }
        temp.updatePixels();
        reset();
        image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
        layers.add(new Layer(temp.pixels, temp.width, temp.height, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2));
      }
    }else if(cState == Cursor.CROPPING) {
      temp = get(0, 20, width-300, height-20);
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
      for(int y = mouseY-20-penSize/2; y <= mouseY-20+penSize/2; y++) {
        for(int x = mouseX-penSize/2; x <= mouseX+penSize/2; x++) {
          if(x >= 0 && x < width-300 && y >= 0 && y < height-20) {
            double distance = Math.sqrt(Math.pow(x-mouseX,2)+Math.pow(y-mouseY+20,2));
            if(Math.round(distance) <= penSize/2) {
              current.add(new Pixel(x, y, primaryColor));
            }
          }
        }
      }
    }else if(mouseButton == RIGHT) {
      fill(secondaryColor);
      stroke(secondaryColor);
      circle(mouseX, mouseY, penSize);
      for(int y = mouseY-20-penSize/2; y <= mouseY-20+penSize/2; y++) {
        for(int x = mouseX-penSize/2; x <= mouseX+penSize/2; x++) {
          if(x >= 0 && x < width-300 && y >= 0 && y < height-20) {
            double distance = Math.sqrt(Math.pow(x-mouseX,2)+Math.pow(y-mouseY+20,2));
            if(Math.round(distance) <= penSize/2) {
              current.add(new Pixel(x, y, secondaryColor));
            }
          }
        }
      }
    }
  }else if(cState == Cursor.CROPPING && !(mouseY <= 18 || mouseX >= width-300)) {
    image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
    stroke(0);
    noFill();
    rect(startX, startY, mouseX-startX, mouseY-startY);
  }
}

void mouseReleased() {
  if(cState == Cursor.DRAWING) {
    if(current != null && current.pixels.size() != 0) {
      layers.add(current);
    }
  }else if(cState == Cursor.MOVING && !(mouseY <= 18 || mouseX >= width-300)) {
    if(layerSelected > 0) {
      endX = mouseX;
      endY = mouseY;
      layers.get(layerSelected).translate(endX-startX, endY-startY);
      updateLayers = true;
    }
  }else if(cState == Cursor.CROPPING && !(mouseY <= 18 || mouseX >= width-300)) {
    endX = mouseX;
    endY = mouseY;
    removeImage = true;
    if(startX < endX && startY < endY) {
      temp = get(startX+1, startY+1, endX-startX-1, endY-startY-1);
    }else if(startX > endX && startY < endY) {
      temp = get(endX+1, startY+1, startX-endX-1, endY-startY-1);
    }else if(startX < endX && startY > endY) {
      temp = get(startX+1, endY+1, endX-startX-1, startY-endY-1);
    }else if(startX > endX && startY > endY) {
      temp = get(endX+1, endY+1, startX-endX-1, startY-endY-1);
    }else {
      removeImage = false;
      updateImage = true;
    }
    reset();
    temp.loadPixels();
    image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
    layers.add(new Layer(temp.pixels, temp.width, temp.height, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2));
  }
}

void waterColor() {
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  color[] newarr = temp.pixels;
  for(int i = 0; i < temp.height; i+=5+5*Math.random()){
    for(int j = 0; j < temp.width; j+=5+5*Math.random()){
      fill(newarr[i*temp.width+j]);
      stroke(newarr[i*temp.width+j]);
      circle(j,i+20,10);
    }
  }
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  reset();
  image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
  layers.add(new Layer(temp.pixels, width-300, height-20));
}

void mosaic() {
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  for(int i = 0; i < temp.height; i+=10){
    for(int j = 0; j < temp.width; j+=10){
      color newcolor;
      ArrayList<Integer> arr = new ArrayList<Integer>();
      for(int y = i; y < 10+i; y++){
        for(int x = j; x < 10+j; x++){
          try{
          arr.add(temp.pixels[y*temp.width+x]);
          }catch(Exception e){}
        }
      }
      int r = 0;
      int g = 0;
      int b = 0;
      for(color a : arr){
       r+=red(a);
       g+=green(a);
       b+=blue(a);
      }
      newcolor = color(r/arr.size(),g/arr.size(),b/arr.size());
      fill(newcolor);
      stroke(0);
      rect(j,i+20,10,10);
    }
  }
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  reset();
  image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
  layers.add(new Layer(temp.pixels, width-300, height-20));
}

void blur() {
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  color[] newarr = temp.pixels;
  for (int i = 0; i < temp.height; i+=3+1*Math.random()) {
    for (int j = 0; j < temp.width; j+=3+1*Math.random()) {
      strokeWeight(1);
      stroke(newarr[i*temp.width+j]);
      line(j, i+20, j-30, i+50);
    }
  }
  temp = get(0, 20, width-300, height-20);
  temp.loadPixels();
  reset();
  image(temp, (width-300)/2-temp.width/2, (height+20)/2-temp.height/2);
  layers.add(new Layer(temp.pixels, width-300, height-20));
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
