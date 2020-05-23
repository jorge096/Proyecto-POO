class Particula{
 float radio;
 float omegaLimite = .05;
 PVector posicion;
 PVector velocidad;
 PVector rotacion;
 float giro;
 int col = 100;
 float amortiguar = 1;
 float esc;

 public Particula(PVector pos, float r_){
   radio  = r_;
   posicion = pos;
   float ang = random(2 * PI);
   velocidad = new PVector(cos(ang), sin(ang));
   velocidad.mult((50*50)/(radio*radio));
   velocidad.mult(sqrt(stage  + 2));
   velocidad.mult(amortiguar);
   ang = random(2 * PI);
   rotacion = new PVector(cos(ang), sin(ang));
   giro = (float)(Math.random()*omegaLimite-omegaLimite/2);
 }

 void separacion(ArrayList<Particula> particulas){
  if(radio <= 30){
   particulas.remove(this);
  } else if (radio < 33){
     for(int i = 0; i < 2; i++){
      float angulo = random(2*PI);
      PVector rand = new PVector(radio*sin(angulo), radio*cos(angulo));
      rand.add(posicion);
      particulas.add(new Particula(rand, radio*.8));
    }
    particulas.remove(this);
  } else {
    for(int i = 0; i < 3; i++){
      float angulo = random(2*PI);
      PVector rand = new PVector(radio*sin(angulo), radio*cos(angulo));
      rand.add(posicion);
      particulas.add(new Particula(rand, radio*.8));
    }
    particulas.remove(this);
  }
 }

 void actualizar(){
   posicion.add(velocidad);
   rotate2D(rotacion, giro);
 }
 void render(){
   fill(col);
   display(posicion.x, posicion.y);
   if (posicion.x < radio){
      display(posicion.x + width, posicion.y);
    } else if (posicion.x > width-radio) {
      display( posicion.x-width, posicion.y);
    }
    if (posicion.y < radio) {
      display(posicion.x, posicion.y + height);
    } else if (posicion.y > height-radio){
      display(posicion.x, posicion.y-height);
    }
 }

 void edges(){
  if (posicion.x < 0){
      posicion.x = width;
    }
    if (posicion.y < 0) {
      posicion.y = height;
    }
    if (posicion.x > width) {
      posicion.x = 0;
    }
    if (posicion.y > height){
      posicion.y = 0;
    }
 }


 void display(float x, float y){
  pushMatrix();
  translate(x,y);
  rotate(heading2D(rotacion)+PI/2);
  noFill();
  strokeWeight (1.5);
  stroke(random(255),random(255),random(255));
  ellipse(0,0,2.1*radio, 1.9*radio);
  
  popMatrix();
 }


float heading2D(PVector pvect){
   return (float)(Math.atan2(pvect.y, pvect.x));
}

void rotate2D(PVector v, float theta) {
  float xTiemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTiemp*sin(theta) + v.y*cos(theta);
}

}


class Bala{
 PVector posicion;
 PVector velocidad;
 int radio = 5;
 int mostrador = 0;
 int tiempo = 24 * 2;
 float alpha;

 public Bala(PVector pos, PVector vel){
  posicion = pos;
  velocidad = vel;
  alpha = 255;
 }

 void bordes(){
  if (posicion.x < 0){
      posicion.x = width;
    }
    if (posicion.y < 0) {
      posicion.y = height;
    }
    if (posicion.x > width) {
      posicion.x = 0;
    }
    if (posicion.y > height){
      posicion.y = 0;
    }
 }

 boolean checkCollision(ArrayList<Particula> asteroids){
   for(Particula a : asteroids){
     PVector dist = PVector.sub(posicion, a.posicion);
     score++;
     if(dist.mag() < a.radio){
      a.separacion(asteroids);
      return true;
     }
     
   }
   return false;
 }

 boolean update(){
   alpha *= .9;
  mostrador++;
  if(mostrador>=tiempo){
    return true;
  }
  posicion.add(velocidad);
  return false;
 }

 void render(){
  fill(0,255,0,98);
  stroke(0,255,0);
  pushMatrix();
  translate(posicion.x, posicion.y);
  rotate(heading2D(velocidad)+PI/2);
  ellipse(0,3, radio*1.5, radio*1.5);
  popMatrix();
 }

float heading2D(PVector pvect){
   return (float)(Math.atan2(pvect.y, pvect.x));
}

}
class Combustible{
  PVector posicion;
  PVector velocidad;
  float diametro;
  color verde;

  public Combustible(PVector pos, PVector vel, color col, int rad){
   posicion = pos;
   velocidad = vel;
   diametro = (float)(Math.random()*rad);
   verde = col;
  }

  void render(){
   noStroke();
   fill(verde);
   ellipse(posicion.x, posicion.y, diametro, diametro);

  }

  void update(){
   posicion.add(velocidad);
   velocidad.mult(.9);
  }
}


class Nave{
 PShape shipShape; 
 PVector posicion;
 PVector velocidad;
 PVector acceleracion;
 PVector rotacion;
 float drag = 0.9;
 float r = 15;


 public Nave(){
  posicion = new PVector(width/2, height/2);
  acceleracion = new PVector(0,0);
  velocidad = new PVector(0,0);
  rotacion = new PVector(0,1);
 }

 void update(ArrayList<Combustible> gas, ArrayList<Combustible> fuego){
   PVector de = new PVector(0, -1.5*r);
   rotate2D(de, heading2D(rotacion)+PI/2);
   de.add(posicion);
   color humo = color(0,255,0,20);

   int  exhaustVolume = (int)(velocidad.mag())+1;
   for(int i = 0; i  <exhaustVolume; i++){
     float angulo = (float)(Math.random()*.5-.25);
     angulo += heading2D(rotacion);
     PVector ADir = new PVector(cos(angulo), sin(angulo));
     gas.add(new Combustible(de, ADir, humo, 15));
   }
   for(int i = 0; i  <1; i++){
     float angulo = (float)(Math.random()*.5-.25);
     angulo += heading2D(rotacion);
     PVector ADir = new PVector(cos(angulo), sin(angulo));
     ADir.y = 0;
     de.add(ADir);
     de.y-=.5;
     color Colorfuego = color(0,(int)( 200+Math.random()*55), 0, 250);
     fuego.add(new Combustible(de,ADir, Colorfuego, 5));
   }
   velocidad.add(acceleracion);
   velocidad.mult(drag);
   velocidad.limit(5);
   posicion.add(velocidad);

 }

 void edges(){
  if (posicion.x < r){
      posicion.x = width-r;
    }
    if (posicion.y < r) {
      posicion.y = height-r;
    }
    if (posicion.x > width-r) {
      posicion.x = r;
    }
    if (posicion.y > height-r){
      posicion.y = r;
    }
 }

 boolean checkCollision(ArrayList<Particula> asteroids){
   for(Particula a : asteroids){
    PVector dist = PVector.sub(a.posicion, posicion);
    if(dist.mag() < a.radio + r/2){
     a.separacion(asteroids);
     return true;
    }
   }
   return false;
 }

 void render(){
   float theta = heading2D(rotacion)  + PI/2;
   theta += PI;

  pushMatrix();
    translate(posicion.x, posicion.y);
    rotate(theta);
    beginShape();                 
    fill(0,255,0,40);                    
    stroke(0,255,0);
    strokeWeight(.6);       
    vertex(0, -17.5);
    vertex(10,0);
    vertex(10,10);
    vertex(0,2.5);
    vertex(-10,10);
    vertex(-10,0);
    vertex(0, -17.5);
    endShape();
   popMatrix();
 }

float heading2D(PVector pvect){
   return (float)(Math.atan2(pvect.y, pvect.x));
}

 void rotate2D(PVector v, float theta) {
  float xTiemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTiemp*sin(theta) + v.y*cos(theta);
}

}

Nave nav;
boolean upPressed = false;//CHANGE LEFT AND RIGHT TO UP AND DOWN( IN SHIP TOO)
boolean downPressed = false;
boolean aPressed = false;
boolean dPressed = false;

float venave = 2;
float rotacionAngulo = .2;
float balara = 10;
int numPart = 1;
int rango = 5000;
int tiempoParaunaNueva = 0; 
int score = 0;
int radiante = 50;

ArrayList<Combustible> gas;
ArrayList<Combustible> fuego;
ArrayList<Bala> balas;
ArrayList<Particula> particulas;
PFont font;
int darkCounter;
int darkCounterLimit = 24*2;
int MAX_LIVES = 3;
int lives;
int stage = -1;
int diffCurve = 2;

void setup(){
 background(0);
 size(800,500);
 font = createFont("Cambria", 32);
 frameRate(24);
 lives = 4;
 particulas = new ArrayList<Particula>(0);

}


void draw(){
 if( lives >= 0 && particulas.size()>0){
   float theta = heading2D(nav.rotacion)+PI/2;
   background(0); 
  
   nav.update(gas, fuego);
   nav.edges();
   nav.render();
   if(nav.checkCollision(particulas)){
    lives--;
    nav = new Nave();
   }
  
   if(aPressed){
     rotate2D(nav.rotacion,-rotacionAngulo);
   }
   if(dPressed){
     rotate2D(nav.rotacion, rotacionAngulo);
   }
   if(upPressed){
     nav.acceleracion = new PVector(0,venave);
     rotate2D(nav.acceleracion, theta);
   }

   for(Combustible e: gas){
    e.update();
    e.render();
   }

   for(Combustible e: fuego){
    e.update();
    e.render();
   }

   for(int i = 0; i < balas.size(); i++){
    balas.get(i).bordes();
    if(balas.get(i).update()){
      balas.remove(i);
      i--;
    }
    if(i < 0){
     break;
    }
    balas.get(i).render();
    if(balas.get(i).checkCollision(particulas)){
      balas.remove(i);
      i--;
    }
   }

    while(gas.size() > 20){
    gas.remove(0);
   }

   while(fuego.size()>3){
    fuego.remove(0);
   }

    while(balas.size() > 30){
    balas.remove(0);
   }

   for(Particula a : particulas){
    a.actualizar();
    a.edges();
    a.render();
   }

   for(int i = 0; i < lives; i++){
     fill(0,240,0);                    
     stroke(0,240,0);
     strokeWeight(.6);  
     rectMode(CORNER);
     rect(30*i + 10,nav.r*1.5,1.5*nav.r,2.5*nav.r);
     text("Score   : " + score, 15, 15);
   }
      if (millis()>tiempoParaunaNueva){
    nuevaParticula();
    tiempoParaunaNueva+= rango;
  }
  println(millis()); 
 } else if(lives < 0){
   if(darkCounter < darkCounterLimit){
    background(0);
    darkCounter++;
    for(Particula a : particulas){
      a.actualizar();
      a.edges();
      a.render();
     }
    fill(0, 255-(darkCounterLimit-darkCounter)*3);
    rect(0,0,width,height);
   } else {
     background(0);
     for(Particula a : particulas){
      a.actualizar();
      a.edges();
      a.render();
     }
     textFont(font, 33);
     fill(0, 200);
     text("GAME OVER", width/2-80-2, height*.75-1);
     textFont(font, 32);
     textFont(font, 16);
     fill(0, 200);
     text("Da click en el mouse para jugar de nuevo", width/2-80-2, height*.9-1);
   }
 } else {
     background(0);
     nav = new Nave();
     nav.render();
     textFont(font, 32);
     fill(255);
         text("VIRUS", width/2-80, height/2);
    

     textFont(font, 15);
     fill(255);
     text("Da click con el mouse para jugar " + (stage + 2), width/2-100, height*.75);
 }
}

void nuevaParticula(){
  float rad = random(30,40);
  float alaeatorioX = 1;
  float alaeatorioY = 1;
  float px=0,py=0;
  PVector pos  = new PVector(px, py);
  if (alaeatorioX<0){
    px = -rad;
  }
  else{
    px = width+rad;
  }
  
  if (alaeatorioY<0){
    py = -rad;
  }
  else{
    py = height+rad;
  }
  
  particulas.add(new Particula(pos, rad));
}

void mousePressed(){
  if(lives < 0){
   stage = -1;
   lives = 4;
   particulas = new ArrayList<Particula>(0);
  } else  if (particulas.size()==0){
   stage++;
   reset();
  }
}


void reset(){
 nav  = new Nave();
 gas = new ArrayList<Combustible>();
 fuego = new ArrayList<Combustible>();
 balas = new ArrayList<Bala>();
 particulas = new ArrayList<Particula>();
  PVector position = new PVector((int)(Math.random()*width), (int)(Math.random()*height-100));
  particulas.add(new Particula(position, radiante));
 
 darkCounter = 0;
}

void disparo(){
  PVector pos = new PVector(0, nav.r*2);
  rotate2D(pos,heading2D(nav.rotacion) + PI/2);
  pos.add(nav.posicion);
  PVector vel  = new PVector(0, balara);
  rotate2D(vel, heading2D(nav.rotacion) + PI/2);
  balas.add(new Bala(pos, vel));
}

void keyPressed(){
  if(key==CODED){
   if(keyCode==UP){
      upPressed=true;
   } else if(keyCode==DOWN){
      downPressed=true;
   } else if(keyCode == LEFT){
    aPressed = true;
   }else  if(keyCode==RIGHT){
    dPressed = true;
   }
  }
  if(key == 'a'){
    aPressed = true;
  }
  if(key=='d'){
   dPressed = true;
  }
  if(key=='w'){
    upPressed=true;
  }
  if(key=='s'){
   downPressed=true;
  }
}

void keyReleased(){
  if(key==CODED){
   if(keyCode==UP){
     upPressed=false;
    nav.acceleracion = new PVector(0,0);
   } else if(keyCode==DOWN){
     downPressed=false;
     nav.acceleracion = new PVector(0,0);
   } else if(keyCode==LEFT){
     aPressed = false;
   } else  if(keyCode==RIGHT){
    dPressed = false;
   }
  }
  if(key=='a'){
   aPressed = false;
  }
  if(key=='d'){
   dPressed = false;
  }
  if(key=='w'){
    upPressed=false;
    nav.acceleracion = new PVector(0,0);
  }
  if(key=='s'){
   downPressed=false;
   nav.acceleracion = new PVector(0,0);
  }
  if(key == ' '){
   disparo();
  }
}


float heading2D(PVector pvect){
   return (float)(Math.atan2(pvect.y, pvect.x));
}

void rotate2D(PVector v, float theta) {
  float xTemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTemp*sin(theta) + v.y*cos(theta);
}
