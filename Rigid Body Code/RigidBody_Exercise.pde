//Rigid Body Dynamics
//CSCI 5611 Physical Simulation [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

class ColideInfo{
  public boolean hit = false;
  public Vec2 hitPoint = new Vec2(0,0);
  public Vec2 objectNormal =  new Vec2(0,0);
}

ColideInfo collisionTest(RigidBody box) {
  box.updateCornerPositions(); // Compute the 4 corners: p1, p2, p3, p4
  ColideInfo info = new ColideInfo();

  // Check for right wall collision
  for (int i = 1; i <= 4; i++) {
    Vec2 corner;
    if (i == 1) corner = box.p1;
    else if (i == 2) corner = box.p2;
    else if (i == 3) corner = box.p3;
    else corner = box.p4;

    if (corner.x > width) {
      info.hitPoint = corner;
      info.hit = true;
      info.objectNormal = new Vec2(-1, 0);
    }
  }

  // Check for left wall collision
  for (int i = 1; i <= 4; i++) {
    Vec2 corner;
    if (i == 1) corner = box.p1;
    else if (i == 2) corner = box.p2;
    else if (i == 3) corner = box.p3;
    else corner = box.p4;

    if (corner.x < 0) {
      info.hitPoint = corner;
      info.hit = true;
      info.objectNormal = new Vec2(1, 0);
    }
  }
  
  // Check for top wall collision
  for (int i = 1; i <= 4; i++) {
    Vec2 corner;
    if (i == 1) corner = box.p1;
    else if (i == 2) corner = box.p2;
    else if (i == 3) corner = box.p3;
    else corner = box.p4;

    if (corner.y < 0) {
      info.hitPoint = corner;
      info.hit = true;
      info.objectNormal = new Vec2(0, 1);
    }
  }
  
  // Check for bottom wall collision
  for (int i = 1; i <= 4; i++) {
    Vec2 corner;
    if (i == 1) corner = box.p1;
    else if (i == 2) corner = box.p2;
    else if (i == 3) corner = box.p3;
    else corner = box.p4;

    if (corner.y > height) {
      info.hitPoint = corner;
      info.hit = true;
      info.objectNormal = new Vec2(0, -1);
    }
  }
  return info;
}

//Set the first box
ArrayList<RigidBody> boxes = new ArrayList<RigidBody>();
RigidBody box1 = new RigidBody(new Vec2(200,200), 70, 70, 0.2);
RigidBody box2 = new RigidBody(new Vec2(400,300), 70, 80, 0.2);

// Force direction: 0: right, 1: left, 2: up, 3: down
int force_dir = 0;

PImage backgroundImage;
ArrayList<Integer> boxColors = new ArrayList<Integer>();

void setup(){
  size(600,400);
  boxes.add(box1);
  boxes.add(box2);
  backgroundImage = loadImage("background.jpg");
  backgroundImage.resize(width, height);
  boxColors.add(color(204, 51, 255));  // Purple
  boxColors.add(color(0, 170, 255));  // Blue
}

//----------
// Physics Functions
void update_physics(float dt){
  //Update center of mass
  for(int i = 0; i<boxes.size(); i++){
    RigidBody box_i = boxes.get(i);
    box_i.momentum.add(box_i.total_force.times(dt));
    Vec2 box_vel = box_i.momentum.times(1.0/box_i.mass);
    box_i.center.add(box_vel.times(dt));
    
    //Angular Momentum = Torque * time
    box_i.angular_momentum += box_i.total_torque * dt;
    
    float angular_vel = box_i.angular_momentum/box_i.rot_inertia;
    box_i.angle += angular_vel * dt;
    
    //Reset forces and torques
    box_i.total_force = new Vec2(0,0);
    box_i.total_torque = 0.0;
  }
}

void draw(){
  background(200); //Grey background
  image(backgroundImage, 0, 0);
  fill(255);
  float dt = 1/frameRate;
  //update_physics(dt);
  float a = -105;
  boolean clicked_box = false;
  
  for(int i = 0; i<boxes.size(); i++){
    RigidBody box_i = boxes.get(i);
    clicked_box = mousePressed && point_in_box(new Vec2(mouseX, mouseY), box_i.center, box_i.w, box_i.h, box_i.angle);
    if (clicked_box) {
      Vec2 force = new Vec2(1,0).times(200);
      //right
      if (force_dir == 0){
        force = new Vec2(1,0).times(200);
        a = 0;
      }
      //left
      else if (force_dir == 1){
        force = new Vec2(-1,0).times(200);
        a = 180;
      }
      //down
      else if (force_dir == 2){
        force = new Vec2(0,1).times(200);
        a = 90;
      }
      //up
      else if (force_dir == 3){
        force = new Vec2(0,-1).times(200);
        a = -90;
      }
      
      Vec2 hit_point = new Vec2(mouseX, mouseY);
      box_i.apply_force(force, hit_point);
    }

    ColideInfo info = collisionTest(box_i);
    Boolean hit_wall = info.hit; //Did I hit the wall
    if (hit_wall){
      Vec2 hit_point = info.hitPoint;
      Vec2 hit_normal = info.objectNormal;
      box_i.resolveCollision(hit_point,hit_normal);
    }

    box_i.total_force.add(new Vec2(0, 100.0)); // gravity
  }
  
  // checking if the boxes collide with each other
  for(int i = 0; i<boxes.size(); i++){
    for (int j = i+1; j<boxes.size(); j++){
      RigidBody box_current = boxes.get(i);
      RigidBody box_next = boxes.get(j);
      ColideInfo info_box = box_current.box_box_collision(box_next);
      if (info_box.hit){
        box_current.resolveBoxCollision(box_next, info_box.hitPoint, info_box.objectNormal);
      }
    }
  }
  
  update_physics(dt);
  
  if (clicked_box){
    fill(255,255,255);
  }
  
  for(int i = 0; i<boxes.size(); i++){
    RigidBody box_i = boxes.get(i);
    fill(boxColors.get(i));
    stroke(boxColors.get(i));
    strokeWeight(4);
    pushMatrix();
    translate(box_i.center.x, box_i.center.y);
    rotate(box_i.angle);
    rect(-box_i.w/2, -box_i.h/2, box_i.w, box_i.h);
    popMatrix();
  }
  
  drawArrow(mouseX, mouseY, 20, a);
}


void keyPressed(){
  if (key == 'r'){
    println("Resetting the simulation");
    for(int i = 0; i<boxes.size(); i++){
      RigidBody box_i = boxes.get(i);
      box_i.momentum = new Vec2(0,0);
      box_i.angular_momentum = 0;
      box_i.center = new Vec2(box_i.init_center.x, box_i.init_center.y);
      box_i.angle = 0.0;
      //box_i.updateCornerPositions();
    }
    return;
  }
  if (keyCode == RIGHT) {
    // apply force to the right
    force_dir = 0;
  }
  if (keyCode == LEFT) {
    // apply force to left
    force_dir = 1;
  }
  if (keyCode == DOWN) {
    // apply force to down
    force_dir = 2;
  }
    
  if (keyCode == UP) {
    // apply force to the up
    force_dir = 3;
  }
}

//Returns true iff the point 'point' is inside the box
boolean point_in_box(Vec2 point, Vec2 box_center, float box_w, float box_h, float box_angle){
  Vec2 relative_pos = point.minus(box_center);
  Vec2 box_right = new Vec2(cos(box_angle),sin(box_angle));
  Vec2 box_up = new Vec2(sin(box_angle),cos(box_angle));
  float point_right = dot(relative_pos,box_right);
  float point_up = dot(relative_pos,box_up);
  if ((abs(point_right) < box_w/2) && (abs(point_up) < box_h/2))
    return true;
  return false;
}

void drawArrow(int cx, int cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  stroke(255, 255, 255);
  strokeWeight(4);
  line(-len,0,0, 0);
  line(0, 0,  - 5, -5);
  line(0, 0,  - 5, 5);
  stroke(0, 0, 0);
  strokeWeight(1);
  popMatrix();
}
