class Cat {
  PImage catImage;
  float xPos, yPos;
  float catImageWidth, catImageHeight;
  PVector nikki;
  
  Cat(float xPos, float yPos, float catImageWidth, float catImageHeight) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.catImageWidth = catImageWidth;
    this.catImageHeight = catImageHeight;
    this.nikki = new PVector();
  } 

  void loadMomoPic() {
    catImage = loadImage("momo_the_cat-1.png");
  }
  
  void drawMomo() {
    imageMode(CENTER);
    image(catImage, this.xPos, this.yPos, this.catImageWidth, this.catImageHeight);
  }
}