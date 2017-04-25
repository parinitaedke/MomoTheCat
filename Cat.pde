class Cat {
  PImage cat;
  float xPos, yPos;
  float catWidth, catHeight;
  PVector nikki;
  
  Cat(float xPos, float yPos, float catWidth, float catHeight) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.catWidth = catWidth;
    this.catHeight = catHeight;
    this.nikki = new PVector();
  } 

  void loadMomoPic() {
    cat = loadImage("momo_the_cat-1.png");
  }
  
  void drawMomo() {
    imageMode(CENTER);
    image(cat, this.xPos, this.yPos, this.catWidth, this.catHeight);
  }
}