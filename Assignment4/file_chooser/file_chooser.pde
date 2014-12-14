import java.util.Collections;
import controlP5.*;
ControlP5 cp5;

String filepath;
String[] attrs = {};
float[][] values;

float xFilterVal;
float yFilterVal;

boolean sortFlag;

int Width = 900;
int Height = 700;
int Padding = 100;


void setup() {
  
  size(Width, Height);
  noStroke();
  cp5 = new ControlP5(this);
  cp5.addButton("csv file chooser")
     .setValue(0)
     .setPosition(Width - 150, 75)
     .setSize(80,30);
     ;
   
  cp5.addButton("Sort Data")
     .setPosition(Width - 150, 110)
     .setSize(80,30);
     ;
     
   cp5.addSlider("X Filter")
   .setPosition(600, 620)
   .setSize(200,10)
   .setRange(0,200)
   ;
   
    // reposition the Label for controller 'slider'
  cp5.getController("X Filter").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("X Filter").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  
  cp5.addSlider("Y Filter")
     .setPosition(600, 650)
     .setSize(200,10)
     .setRange(0,200)
     ;
     
  // reposition the Label for controller 'slider'
  cp5.getController("Y Filter").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("Y Filter").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   
}

public void controlEvent(ControlEvent theEvent) {
  if(theEvent.getController().getName() == "csv file chooser"){ 
    selectInput("Select a csv file to process:", "fileSelected");
  }
   
  if(theEvent.getController().getName() == "X Filter"){
    xFilterVal = theEvent.getController().getValue();  
  }
  
  if(theEvent.getController().getName() == "Y Filter"){
    yFilterVal = theEvent.getController().getValue();
  }
  
  if(theEvent.getController().getName() == "Sort Data"){
    if(sortFlag == false){
      sortFlag = true;
    } else {
      sortFlag = false;
    }
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    filepath = selection.getAbsolutePath();
    println("User selected " + filepath);
    
    readCSVFile(filepath);
  }
}

void readCSVFile(String fileName){
  BufferedReader reader = createReader(fileName);
  
  try{
    String header = reader.readLine();
    attrs = header.split(",");
  } catch(IOException e){
    e.printStackTrace();
  }
  
  Table table = loadTable(fileName, "header");
  values = new float[attrs.length][table.getRowCount()];
  for (int i = 0; i < attrs.length; i++){
    for (int j = 0; j < table.getRowCount(); j++){
      
      float value = table.getRow(j).getFloat(attrs[i]);
      values[i][j] = value;
      
    }
//    println(values[i]);
  }
  
  cp5.getController("X Filter").setValue(200);
  cp5.getController("Y Filter").setValue(200);
}


void draw(){
  background(#80343A);
  smooth();
  if(attrs.length == 1){
    barChart();
  } else if(attrs.length == 2){
    scatterPlot();
  } else if(attrs.length > 2){
    scatterPlotMatrix();
  }
}

public void drawAxes(String visName){
  
  stroke(#909091);
  strokeWeight(1);
  fill(#909091);
  
  int x1 = Padding;
  int x2 = width - Padding;
  int y1 = height - Padding;
  int y2 = y1;
  line(x1, y1, x2, y2);
  
  if(visName == "Scatter Plot"){
    int tick = 10;
    int gap = (width - Padding * 2) / 5;
      for (int j = 0; j < 5; j++) {
        line(x1 + (j + 1) * gap, y1, x1 + (j + 1) * gap, y1 + tick);
      }
      text(attrs[0], x2, y2 - 10);
  }
  
  x1 = Padding;
  x2 = x1;
  y1 = Height - Padding;
  y2 = Padding + 30;
  line(x1, y1, x2, y2);
  
  int gap = (y1 - y2) / 5;
  int tick = 10;
  for (int j = 0; j < 5; j++) {
      line(x1, y2 + j * gap, x1 - tick, y2 + j * gap);
  }
  
  if (visName == "Bar Chart") {
    text(attrs[0], x1, y2 - 15);
  } else {
    text(attrs[1], x1, y2 - 15);
  }
  
}

public void barChart(){
  
  cp5.getController("Sort Data").show();
  cp5.getController("Y Filter").show();
  textSize(20);
  text("Bar Chart", Width/2 - 100, 75);
  fill(#34807A);
  drawAxes("Bar Chart");
  cp5.getController("X Filter").hide();
  float[] barValues;
  int total;
  float maxVal;
  float minVal;
  
  barValues = values[0];
  total = barValues.length;
  
  maxVal = sort(barValues)[total - 1];
  minVal = sort(barValues)[0];
  cp5.getController("Y Filter").setMin(minVal);
  cp5.getController("Y Filter").setMax(maxVal);
  
  ArrayList<Float> selectedBars = new ArrayList<Float>();
  
  for(Float val : barValues){
    if (val <= yFilterVal){
      selectedBars.add(val);
    }
  }
  
  if(sortFlag) {
    Collections.sort(selectedBars); 
  }
  
  total = selectedBars.size();
  
  int maxHeight = height - 2 * Padding - 30;
  int barWidth = (width - 2 * Padding) / total;
  
  
   for (int i = 0; i < total; i++){
     int barHeight = int(selectedBars.get(i) / maxVal * maxHeight);
     int xPos = Padding + (barWidth * i);
     int yPos = height - barHeight - Padding;   
     noStroke();       
     if(xPos < mouseX && mouseX < xPos + barWidth &&
        yPos < mouseY && mouseY < height - Padding){
           fill(#BA3AAF);
           textSize(24);
           text(String.format("%d", int(selectedBars.get(i))), mouseX, mouseY - 30);
        }     
     else{fill(#3AAFBA);}
     rect(xPos, yPos, barWidth - 5, barHeight);
   }
  
  
  stroke(#343A80);
  fill(#343A80);
  for (int j = 0; j < 5; j++) {
    text(int(maxVal * (5 - j) / 5), Padding - 50, Padding + 30 + (height - 2 * Padding) * j / 5 );
  }
}

public void scatterPlot(){
  
  float xMin;
  float xMax;
  float yMin;
  float yMax;
  float[] xVals;
  float[] yVals;
  
  cp5.getController("Sort Data").hide();
  cp5.getController("X Filter").show();
  cp5.getController("Y Filter").show();
  fill(#34807A);
  textSize(20);
  text("Scatter Plot", Width/2 - 100, 100);
  
  drawAxes("Scatter Plot");
  
  xVals = values[0];
  yVals = values[1];
  
  int xTotal = xVals.length;
  int yTotal = yVals.length;
  
  xMin = sort(xVals)[0];
  xMax = sort(xVals)[xTotal - 1];
  yMin = sort(yVals)[0];
  yMax = sort(yVals)[yTotal - 1];
  
  cp5.getController("X Filter").setMin(xMin);
  cp5.getController("X Filter").setMax(xMax);
  cp5.getController("Y Filter").setMin(yMin);
  cp5.getController("Y Filter").setMax(yMax);
  
  ArrayList<PVector> selectedPoints = new ArrayList<PVector>();
  
  for (int i = 0; i < xVals.length; i++) {
    if (xVals[i] <= xFilterVal && yVals[i] <= yFilterVal) {
      PVector newPoint = new PVector(xVals[i], yVals[i]); 
      selectedPoints.add(newPoint);
    }
  }
  
  int gap = (width - 2 * Padding) / 5;
  for (int j = 0; j < 5; j++){
    text(int(xFilterVal * j / 5), Padding + j * gap, height - Padding + 10);
    text(int(yFilterVal * (5 - j) / 5), Padding - 35, Padding + 30 + (height - 2 * Padding) * j / 5);
  }
  
  for(PVector point : selectedPoints){
    int xPos =  int(map(point.x, 0, xFilterVal, Padding, width - Padding));
    int yPos = int(map(point.y, 0, yFilterVal, height - Padding, Padding + 30 ));
    
    if (abs(mouseX - xPos) < 10 && abs(mouseY - yPos) < 10){    
      noStroke();
      fill(#3AAFBA);
      ellipse(xPos, yPos, 12, 12);
      text(point.x + ", " + point.y, mouseX + 15, mouseY + 10);
    } 
    else {
      noStroke();
      fill(#BA3AAF);
      ellipse(xPos, yPos, 10, 10);
    }
  }  
}  
  
  
public void scatterPlotMatrix(){
  cp5.getController("Sort Data").hide();
  cp5.getController("X Filter").hide();
  cp5.getController("Y Filter").hide();
  
  fill(#34807A);
  textSize(20);
  text("Scatter Plot Matrix", Width/2 - 100, 100);
  
  int gapLine = 5;
  int num = attrs.length;
  
  stroke(#909091);
  strokeWeight(1);
  fill(#909091);
  
  int x1 = Padding;
  int x2 = width - Padding + 50;
  int y1 = height - Padding;
  int y2 = y1;
  line(x1, y1, x2, y2);
  
  x1 = Padding;
  x2 = x1;
  y1 = Height - Padding;
  y2 = Padding + 30;
  line(x1, y1, x2, y2);
  
  int blockSizeX = (width - 2 * Padding) / num;
  int blockSizeY = (height - 2 * Padding - 80) / num;
  
  for (int i = 1; i <= num; i++){
    x1 = Padding + i * blockSizeX;
    y1 = height - Padding;
    x2 = x1;
    y2 = Padding + 80; 
    line(x1, y1, x2, y2);
    
    int gap = blockSizeX / 5;
    int tick = 5;
  
    x1 = Padding;
    y1 = height - Padding - i * blockSizeY;
    x2 = width - Padding;
    y2 = y1;
    line(x1, y1, x2, y2);
  }
    
  for(int i = 0; i < num; i++){
    for (int j = 0; j < num; j++){
      String attr1 = attrs[i];
      String attr2 = attrs[j];
      
      text(attr1, Padding + 20 + i * blockSizeX, height - Padding - 50 - i * blockSizeY);
      
      float[] vals1 = values[i];
      float[] vals2 = values[j];
      
      int total1 = vals1.length;
      int total2 = vals2.length;
      
      float max1 = sort(vals1)[total1 - 1];
      float max2 = sort(vals2)[total2 - 1];
         
      int gapVal1 = int(max1 / 5);
      int gapVal2 = int(max2 / 5);
      
      ArrayList<PVector> selectedPoints = new ArrayList<PVector>();
      
      for(int m = 0; m < total1; m++){
        PVector point = new PVector(vals1[m], vals2[m]);
        selectedPoints.add(point);
      }
      
      for(PVector point : selectedPoints){
        int xPos =  int(map(point.x, 0, max1, Padding + i * blockSizeX,   Padding + i * blockSizeX + blockSizeX));
        int yPos = int(map(point.y, 0, max2, height - Padding - j * blockSizeY, height - Padding - j * blockSizeY - blockSizeY));
        
        if (abs(mouseX - xPos) < 5 && abs(mouseY - yPos) < 5){    
          
          fill(#F5DE33);
          ellipse(xPos, yPos, 10, 10);
          text(point.x + ", " + point.y, mouseX + 15, mouseY + 10);
          
        } else {  
          fill(#3AAFBA);
          ellipse(xPos, yPos, 5, 5);
        }
      }
      
      int gapX = blockSizeX / 5;
      int gapY = blockSizeY / 5;
      int tick = 5;
      
      for (int n = 0; n < 5; n++) {
        int startX= Padding + i * blockSizeX + n * gapX; 
        int endX = startX;
        int startY = height - Padding;
        int endY = startY + 5;
        
        int startX2= Padding; 
        int endX2 = startX2 - 5;
        int startY2 = height - Padding - i * blockSizeY - n * gapY;
        int endY2 = startY2;
        
        fill(#34807A);
        line(startX, startY, endX, endY);
        line(startX2, startY2, endX2, endY2);
        
        text(n * gapVal1, endX, endY + 10);
        text(n * gapVal2, endX2 - 30, endY2);
      }
      
      

    }
  }
}

  
  
