import java.util.Random;

//GAME PARAMETERS --- EDIT HERE - ~12-17% mines is good

int squareSize = 50;//             50
int mapSize = 800;//               800 
int mines = 40;//                   40
int numSpaces = 256;//             256

boolean BIGGAME = true;//10,000 spaces game
boolean humanPlaying = false;
//END GAME PARAMETERS

boolean gameStarted = false; 
boolean gameOver = false;
boolean delayDraw = false;
boolean justDelayed = false;
int delayBy = 0;
int delayIn = 3;

Space[] spaces = new Space[numSpaces];
ArrayList<Space> discoveredSpaces = new ArrayList<>();
/*  Beginner - 9 * 9 Board and 10 Mines
    Intermediate - 16 * 16 Board and 40 Mines
    Advanced - 24 * 24 Board and 99 Mines      */

void settings() {
  if(BIGGAME){
    squareSize = 10;
    mapSize = 1000; 
    mines = 1500;
    numSpaces = 10000;
    spaces = new Space[numSpaces];
  }
  size(mapSize, mapSize);
}

void setup(){
  background(130);
  int i = 0;
  for(int x = 0; x < mapSize; x+=squareSize) {//columns
    for(int y = 0; y < mapSize; y+=squareSize) {//rows
      spaces[i] = new Space(false, new int[]{x,x + squareSize}, new int[]{y,y + squareSize});
      i++;
    }
  }
  drawMap();
  if(!humanPlaying){
    Random random = new Random();
    clickSpace(spaces[random.nextInt(numSpaces)]);
  }
}

void draw(){
  drawMap();
  if(delayDraw){
    delayIn--;
    if(isWinState())
      showEndGameMessage(true);
    else
      showEndGameMessage(false);
  }
  if(delayIn == 0){
    delay(delayBy);
    delayDraw = false;
    justDelayed = true;
    reset();
    delayIn = 3;
  }
  if(!gameOver)
    clickSpace(smartMove());
}

void mousePressed(){
  if(humanPlaying){
    if (mouseButton == LEFT) {
      Space clickedSpace = getSpaceFromPos(getMousePos());
      clickSpace(clickedSpace);
    } else if (mouseButton == RIGHT) {
      Space clickedSpace = getSpaceFromPos(getMousePos());
      flagSpace(clickedSpace);
    }else{//MIDDLE
      for(Space space:spaces){
        space.discovered = true;
      }
    }
  }
}

void drawMap(){
  for(Space space:spaces){
    space.drawSpace();
  }
}

void setMines(Space firstClickSpace){//SET SO THAT 
  Random random = new Random();
  
  for(int i = 0; i < mines; i++){
    boolean uniqueFound = false;
    while(!uniqueFound){
      int chosenMine = random.nextInt(numSpaces);
      if(!spaces[chosenMine].isMine() && spaces[chosenMine] != firstClickSpace){//if isn't already a mine and isn't first click pos
        spaces[chosenMine].setMine();
        uniqueFound = true;
      }
    }
  }
}

float[] getMousePos(){
  return new float[] {mouseX, mouseY};
}

Space getSpaceFromPos(float[] pos){
  for(Space s:spaces){
    if(pos[0] >= s.xBounds[0] && pos[0] <= s.xBounds[1] 
    && pos[1] >= s.yBounds[0] && pos[1] <= s.yBounds[1])//if within bounds
      return s;
  }
  return null;
}

// NEIGHBORS OF X   0 1 2
//                  3 X 4
//                  5 6 7
void setSpaceNeighbors(){
  for(Space s:spaces){
    float[] sPos = {s.xBounds[0] + 1, s.yBounds[0] + 1};
    s.neighbors[0] = getSpaceFromPos(new float[]{sPos[0] - squareSize,sPos[1] - squareSize});
    s.neighbors[1] = getSpaceFromPos(new float[]{sPos[0],sPos[1] - squareSize});
    s.neighbors[2] = getSpaceFromPos(new float[]{sPos[0] + squareSize,sPos[1] - squareSize});
    s.neighbors[3] = getSpaceFromPos(new float[]{sPos[0] - squareSize,sPos[1]});
    s.neighbors[4] = getSpaceFromPos(new float[]{sPos[0] + squareSize,sPos[1]});
    s.neighbors[5] = getSpaceFromPos(new float[]{sPos[0] - squareSize,sPos[1] + squareSize});
    s.neighbors[6] = getSpaceFromPos(new float[]{sPos[0],sPos[1] + squareSize});
    s.neighbors[7] = getSpaceFromPos(new float[]{sPos[0] + squareSize,sPos[1] + squareSize});
  }
}

void setSpaceValues(){
  for(Space s:spaces){
    for(Space neighbor:s.getNeighbors()){
        if(neighbor.isMine())
          s.numMines++;
    }
  }
}

void chainDiscover(Space s){//if s numMines = 0, chain discover all neighboring numMines = 0 spaces, and then discover all of their neighbors
  if(s.numMines == 0 && !s.isMine()){
    s.setDiscovered();
    Space[] neighbors = s.getNeighbors();
    for(Space neighbor:neighbors){
      if(neighbor.numMines == 0 && !neighbor.isDiscovered())
        chainDiscover(neighbor);
    }
  }
}

void postChainDiscover(){//discover all neighbors of numMines = 0 spaces
  for(Space s: spaces)
    if(s.numMines == 0 && s.isDiscovered())//if empty discovered space
      for(Space neighbor:s.getNeighbors())
        neighbor.setDiscovered();
        
}

boolean isWinState(){
  for(Space s:spaces){
    if((s.isMine() && !s.isFlagged()) || (!s.isMine() &&  !s.isDiscovered()))//if mine and not flagged, or not mine and not discovered
      return false;
  }
  return true;
}

void showEndGameMessage(boolean win){
  if(win){
    fill(200,200,170);
    rect(mapSize/3.5 - mapSize/20, mapSize/2 - mapSize/10, mapSize/2.2, mapSize/7.5);
    fill(255,255,255);
    rect(mapSize/3.5 - mapSize/25, mapSize/2 - mapSize/12, mapSize/2.3, mapSize/10);
    fill(0,255,0);
    textSize(mapSize/10);
    text("You Win!", mapSize/3.5, mapSize/2);
  }else{//LOSE
    //draw outer boxes
    fill(200,200,170);
    rect(mapSize/3.5 - mapSize/20, mapSize/2 - mapSize/10, mapSize/2, mapSize/7.5);
    fill(255,255,255);
    rect(mapSize/3.5 - mapSize/25, mapSize/2 - mapSize/12, mapSize/2.1, mapSize/10);
    //draw text
    fill(255,0,0);
    textSize(mapSize/10);
    text("You Lose!", mapSize/3.5, mapSize/2);
  }
  delayDraw(4000);
}

void delayDraw(int ms){//delays NEXT draw, draw updates at the END
  delayDraw = true;
  delayBy = ms;
}

void reset(){
  gameStarted = false;
  gameOver = false;
  spaces = new Space[numSpaces];
  discoveredSpaces.clear();
  setup();
}

void clickSpace(Space s){
  if(s == null)
    return;
  if(!gameStarted){
    setMines(s);
    setSpaceNeighbors();
    setSpaceValues();
    gameStarted = true;
  }
  s.setDiscovered();
  s.drawSpace();
  if(s.isMine()){
    gameOver = true;
    showEndGameMessage(false);
  }
  else{//if not gameover
    chainDiscover(s);
    postChainDiscover();
    
    if(isWinState())
      showEndGameMessage(true);
  }
}

void flagSpace(Space s){
  s.toggleFlag();
  if(isWinState())
      showEndGameMessage(true);
}



Space smartMove(){
  //  place all guaranteed flags -                             num non discovered neighbors = numMines -> place flags to all non discovered neighbors
  boolean flagPlaced = true;
  while(flagPlaced){
    flagPlaced = false;
    for(Space s : discoveredSpaces){
      Space[] nonDiscNeighbors = s.getNonDiscoveredNeighbors();
      if(nonDiscNeighbors.length == s.numMines && s.numMines > 0){
        for(Space neig : nonDiscNeighbors)
          if(!neig.isFlagged()){
            flagSpace(neig);
            flagPlaced = true;
          }
      }
    }
  }
  //  check for safe spaces - choose                               numMines == numFlaggedNeighbors -> all other neighbors are safe
  for(Space s : discoveredSpaces){
    if(s.numMines == s.numFlaggedNeighbors()){
      for(Space neighbor: s.getNonDiscoveredNeighbors()){
        if(!neighbor.isFlagged())
          return neighbor;
      }
    }
  }
  //  calculate safest space and choose                           s.probBombFromChooseRandNeig = (s.numMines - s.numFlaggedNeig) / numNonFlaggedNonDiscoveredNeig  <- Add this probability to all neighboring spaces' choice value
  
  //for each unknown border space, count the number of discovered neighbors touching it, choose one tied for lowest   s.probBomb = sum of discovered neighbors' num Mines minus their already flagged mines
  ArrayList<Space> unkSpaces = new ArrayList<>();
  for(Space discSpace : discoveredSpaces){
    for(Space unkSpace : discSpace.getUnkNeighbors())
      if(!unkSpaces.contains(unkSpace))
        unkSpaces.add(unkSpace);
  }
  if(unkSpaces.size() > 0){
    int[] probBomb = new int[unkSpaces.size()];
    int min = 99;
    int minIndex = -1;
    for(int i = 0; i < probBomb.length; i++){
      probBomb[i] = unkSpaces.get(i).sumDiscoveredNeighbors();
      if(probBomb[i] < min){
        min = probBomb[i];
        minIndex = i;
      }
    }
    System.out.println("Inferring");
    return unkSpaces.get(minIndex);
  }
  System.out.println("Guessing");
  for(Space s : spaces)
    if(!s.isFlagged() && !s.isDiscovered())
      return s;
  return null;
}
