class Space{
  boolean mine = false;
  boolean flagged = false;
  boolean discovered = false;
  Space[] neighbors = new Space[8];                                    // NEIGHBORS OF X   0 1 2
  int xBounds[] = new int[2];                                          //                  3 X 4
  int yBounds[] = new int[2];                                          //                  5 6 7
  int numMines = 0;
  public Space(boolean mineStatus, int[] xBounds, int[] yBounds){
    this.mine = mineStatus;
    this.xBounds[0] = xBounds[0];
    this.xBounds[1] = xBounds[1];
    this.yBounds[0] = yBounds[0];
    this.yBounds[1] = yBounds[1];
  }
  
  boolean isDiscovered(){
    return this.discovered; 
  }
  
  boolean isMine(){
    return this.mine;
  }
  
  boolean isFlagged(){
    return this.flagged;
  }
  
  Space[] getNeighbors(){
    ArrayList<Space> nonNullNeighbors = new ArrayList<>();
    for(Space s:this.neighbors){
      if(s != null)
        nonNullNeighbors.add(s);
    }
    return nonNullNeighbors.toArray(new Space[0]);
  }
  
  void setMine(){
    this.mine = true;
  }
  
  void toggleFlag(){
    this.flagged = !this.flagged;
  }
  
  void setDiscovered(){
    this.discovered = true;
  }
  
  void drawSpace(){
    if(!isDiscovered()){
      fill(100,160,100);//undiscovered color
      rect(xBounds[0],yBounds[0],xBounds[1] - xBounds[0],yBounds[1] - yBounds[0]);
      if(flagged){
        float xCenter = xBounds[0] + (xBounds[1] - xBounds[0])/2;
        float yCenter = yBounds[0] + (yBounds[1] - yBounds[0])/1.75;
        fill(220,240,240);
        rect(xCenter - squareSize/15, yCenter - squareSize/8, squareSize/8, squareSize/3);//pole
        rect(xCenter - squareSize/3, yCenter + squareSize/5, squareSize/1.5, squareSize/8);//base
        fill(255,0,0);
        triangle(xCenter - squareSize/15 + squareSize/8, yCenter - squareSize/3, xCenter - squareSize/15 + squareSize/8, yCenter - squareSize/8, xCenter - squareSize/3,  yCenter - squareSize/5);//flag
        
      }
    }else{
      fill(95,80,65);
      rect(xBounds[0],yBounds[0],xBounds[1] - xBounds[0],yBounds[1] - yBounds[0]);
      float xCenter = xBounds[0] + (xBounds[1] - xBounds[0])/2;
      float yCenter = yBounds[0] + (yBounds[1] - yBounds[0])/1.75;
      if(isMine()){//show mine
        fill(255,0,0);//undiscovered color
        rect(xBounds[0],yBounds[0],xBounds[1] - xBounds[0],yBounds[1] - yBounds[0]);
        fill(0,0,0);
        ellipse(xCenter, yCenter, squareSize/2, squareSize/4);
        ellipse(xCenter, yCenter - squareSize/10, squareSize/10, .3 * squareSize);
        triangle(xCenter - (.17 * squareSize), yCenter - (.17 * squareSize), xCenter + (.17 * squareSize), yCenter - (.17 * squareSize), xCenter, yCenter);
      }else{//show text
        fill(0,0,0);
        textSize(squareSize/2);
        if(numMines > 0)
          text(numMines, xCenter - squareSize/10, yCenter + squareSize/10);
      }
    }
  }
}
