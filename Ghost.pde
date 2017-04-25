class Ghost {
  PImage ghost_1;
  PVector pos;
  float ghostWidth, ghostHeight;

  PVector target;
  float ghostSpeed;

  PImage life;
  int ghostLife;

  
  Ghost(float xPos, float yPos, float ghostWidth, float ghostHeight) {
    this.pos = new PVector(xPos, yPos);
    this.ghostWidth = ghostWidth;
    this.ghostHeight = ghostHeight;
    this.ghostSpeed = 1;
    this.target = new PVector();
    
    int i = floor(random(4));
    life = lives[i];
    ghostLife = i;
    
    loadGhostPic();
  }

  void loadGhostPic() {
    ghost_1=loadImage("ghost-1.png");
  }
  
  void drawGhost() {
    imageMode(CENTER);
    image(ghost_1, this.pos.x, this.pos.y, this.ghostWidth, this.ghostHeight);
    image(life, pos.x, pos.y-this.ghostHeight/2, this.ghostWidth/2, this.ghostHeight/2);
  }

  void updateGhost() {
    tigger.nikki.set(tigger.xPos, tigger.yPos);
    target = PVector.sub(tigger.nikki, pos);
    target.normalize();
    target.mult(ghostSpeed);
    pos.add(target);
  }
}