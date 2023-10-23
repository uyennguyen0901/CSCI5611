import peasy.*;

PeasyCam cam;
PImage cloth;

int numBalls = 30;
int threads = 30;
final float dt = 0.001;
float floor = 500;
Vec3 gravity = new Vec3(0, 10, 0);
float restLen = 5;
float k = 100; 
float kv = 10;
float bounce = -.1;
float sphereBounce;
float keySpeed = 2;
float startTime, elapsedTime = dt;
int updateRate = 140;
int sphereRadius = 50;
boolean fixed = true;
float mass = 2; 
Vec3 spherePosition = new Vec3(270, 310, 100);
Node[][] springArray = new Node[threads][numBalls];
Node draggedNode = null;
// Air Drag and Wind parameters
float rho = 1.225;    // Air density in kg/m^3
float Cd = 1;      // Drag coefficient for a sphere, can adjust for cloth
float A = 0.001;      // Effective area for each node, can adjust as needed
Vec3 windForce = new Vec3(1, 0, 0);
Ball thrownBall = new Ball(new Vec3(250, 250, 250), new Vec3(0, -1, 0), 5);
float MAX_FORCE = 2000;
boolean ballActive = false;
// Add the Ball class
class Ball {
    Vec3 pos;
    Vec3 vel;
    float radius;

    Ball(Vec3 position, Vec3 velocity, float r) {
        pos = position;
        vel = velocity;
        radius = r;
    }

    void update(float dt) {
        pos.add(vel.times(dt));
    }

    void detectCollisionWithCloth() {
        for (int i = 0; i < threads; i++) {
            for (int j = 0; j < numBalls; j++) {
                float distanceToBall = springArray[i][j].pos.distanceTo(pos);
                if (distanceToBall <= radius) {
                    Vec3 normal = springArray[i][j].pos.minus(pos).normalized();
                    Vec3 pushOut = normal.times(radius - distanceToBall);
                    springArray[i][j].pos.add(pushOut);
                    float velDotNormal = springArray[i][j].vel.dot(normal);
                    if (velDotNormal < 0) {
                        Vec3 reflection = normal.times(-0.05 * velDotNormal);
                        springArray[i][j].vel.add(reflection);
                    }
                }
            }
        }
    }
}






void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, spherePosition.x, spherePosition.y,50, 400);
  cam.setYawRotationMode();
  cloth = loadImage("cloth.png");

  createCloth();
}

void createCloth() {
  for (int i = 0; i < threads; i++) {
    for (int j = 0; j < numBalls; j++) {
      // Calculate the positions based on the row and column
      float x = 200 + restLen * i;
      float y = 200 ; 
      float z = restLen * 1.5 * j; // Set z-coordinate as needed
      
      springArray[i][j] = new Node(new Vec3(x, y, z), new Vec3(0, 0, 0));
    }
  }
}

void update(float dt) {
    if (fixed) { 
        for (int i = 0; i < threads; i++) {
            springArray[i][0].vel = new Vec3(0, 0, 0);
            springArray[i][0].pos = new Vec3(200 + restLen * i, 200, 0);
        }
    }

    for (int i = 0; i < threads; i++) {
        for (int j = 0; j < numBalls; j++) {
            Vec3 totalForce = gravity.plus(windForce);
            
            if (!(fixed && j == 0)) {  // Skip gravity for the fixed top row
                springArray[i][j].vel.add(totalForce.times(dt));
            }
            springArray[i][j].pos.add(springArray[i][j].vel.times(dt));
            
            // Calculate drag force
            float vMag = springArray[i][j].vel.magnitude();
            if (vMag > 0.01) {  // Only calculate drag if velocity is above a threshold
                Vec3 dragDirection = springArray[i][j].vel.times(-1).normalized();
                float dragMagnitude = 0.5 * rho * vMag * vMag * Cd * A;
                Vec3 dragForce = dragDirection.times(dragMagnitude);
                springArray[i][j].vel.add(dragForce.times(dt).divide(mass));
                springArray[i][j].vel.add(windForce.times(dt).divide(mass));
            }
            
            // Check if this node is in collision with the ball
            float distanceToBall = springArray[i][j].pos.distanceTo(thrownBall.pos);
            if (distanceToBall <= thrownBall.radius + restLen) { // Increased the collision boundary
                Vec3 collisionForce = springArray[i][j].pos.minus(thrownBall.pos).times(-k * 5); // Amplified the force
                totalForce.add(collisionForce);
            }
            
            // Check if the force exceeds the threshold
            if (totalForce.magnitude() > MAX_FORCE) {
                springArray[i][j].torn = true;
                // Add randomness to tearing logic
                if (i > 0 && random(1.0) < 0.2) springArray[i-1][j].torn = true;
                if (i < threads - 1 && random(1.0) < 0.2) springArray[i+1][j].torn = true;
                if (j > 0 && random(1.0) < 0.2) springArray[i][j-1].torn = true;
                if (j < numBalls - 1 && random(1.0) < 0.2) springArray[i][j+1].torn = true;
            }
        }
    }

    for (int i = 0; i < threads - 1; i++) {
        for (int j = 0; j < numBalls; j++) {
            Vec3 energy = springArray[i + 1][j].pos.minus(springArray[i][j].pos);
            float v1, v2 = 0;
            float force = 0;
            float length = (energy.dot(energy));
            energy.normalize();
            v1 = energy.dot(springArray[i][j].vel);
            v2 = energy.dot(springArray[i + 1][j].vel);
            force = -k * (restLen - sqrt(length)) - kv * (v1 - v2);
            energy.y /= mass;
            springArray[i][j].vel.add(energy.times(force * dt));
            springArray[i + 1][j].vel.subtract(energy.times(force * dt));
        }
    }

    for (int i = 0; i < threads; i++) {
        for (int j = 0; j < numBalls-1; j++) {
            Vec3 energy = springArray[i][j+1].pos.minus(springArray[i][j].pos);
            float v1, v2 = 0;
            float force = 0;
            float length = (energy.dot(energy));
            energy.normalize();
            v1 = energy.dot(springArray[i][j].vel);
            v2 = energy.dot(springArray[i][j + 1].vel);
            force = -k * (restLen - sqrt(length)) - kv * (v1 - v2);
            energy.y /= mass;
            springArray[i][j].vel.add(energy.times(force * dt));
            springArray[i][j + 1].vel.subtract(energy.times(force * dt));
        }
    }

    detectCollision();
    if (ballActive) {
        thrownBall.update(dt);
        thrownBall.detectCollisionWithCloth();
    }
}

void detectCollision(){

   for (int i = 0; i < threads; i++) {
        for (int j = 0; j < numBalls; j++) {
            float distanceToSphere = springArray[i][j].pos.distanceTo(spherePosition);
            if (distanceToSphere <= sphereRadius) {
                Vec3 normal = springArray[i][j].pos.minus(spherePosition).normalized();
                Vec3 pushOut = normal.times(sphereRadius - distanceToSphere);
                springArray[i][j].pos.add(pushOut);
                // Reflect the velocity based on the collision
                float velDotNormal = springArray[i][j].vel.dot(normal);
                if (velDotNormal < 0) {
                    Vec3 reflection = normal.times(-0.05 * velDotNormal);
                    springArray[i][j].vel.add(reflection);
                }
            }
        }
    }

    // Handle collisions with the ground
    for (int i = 0; i < threads; i++) {
        for (int j = 0; j < numBalls; j++) {
            if (springArray[i][j].pos.y > floor) {
                springArray[i][j].vel.y *= bounce;
                springArray[i][j].pos.y = floor;
            }
        }
    }
  
}

void draw() {
  startTime = millis();
  pushMatrix();
  translate(width/2, height/2, -1000);  // Place it far in the background
  noStroke();
  beginShape(QUADS);
 
  vertex(-width*2, -height*2, 0, 0, 0);  // Make the rectangle larger than the canvas
  vertex(width*2, -height*2, 0, 1, 0);
  vertex(width*2, height*2, 0, 1, 1);
  vertex(-width*2, height*2, 0, 0, 1);
  endShape();
  popMatrix();
  lights();
  background(140);
  for (int i = 0; i < updateRate; i++) {
    update(elapsedTime);
  }
   drawSphere();
  drawCloth();
 
  elapsedTime = (millis() - startTime) / 25000;
  if (draggedNode != null) {
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse(draggedNode.pos.x, draggedNode.pos.y, 10, 10); 
  }
  if (ballActive) {
        // Draw the ball (you can adapt this to your needs)
        pushMatrix();
        translate(thrownBall.pos.x, thrownBall.pos.y, thrownBall.pos.z);
        fill(200);
        specular(172, 142, 250);
        lightSpecular(155, 2, 25);
        directionalLight(204, 102, 0, 0, 1, 0);
        sphere(thrownBall.radius);
        popMatrix();
    }
}


void drawSphere() {
  pushMatrix();
  translate(spherePosition.x, spherePosition.y, spherePosition.z);
  fill(60);
  specular(60, 60, 67);
  lightSpecular(133, 133, 140);
  directionalLight(204, 102, 0, 0, 1, 0);
  sphere(sphereRadius);
  popMatrix();
}

void drawCloth() {
    noStroke();
    strokeWeight(2);
    fill(255);
    textureWrap(REPEAT);
    textureMode(NORMAL);
    hint(DISABLE_DEPTH_TEST);
    for (int i = 0; i < threads - 1; i++) {
        for (int j = 0; j < numBalls - 1; j++) {
            if (!springArray[i][j].torn && !springArray[i+1][j].torn && 
                !springArray[i][j+1].torn && !springArray[i+1][j+1].torn) {
                
                // Calculate texture coordinates based on the current i and j
                float u1 = map(i, 0, threads - 1, 0, 1);
                float u2 = map(i + 1, 0, threads - 1, 0, 1);
                float v1 = map(j, 0, numBalls - 1, 0, 1);
                float v2 = map(j + 1, 0, numBalls - 1, 0, 1);

                beginShape(TRIANGLE_STRIP);
                texture(cloth);
                vertex(springArray[i][j].pos.x, springArray[i][j].pos.y, springArray[i][j].pos.z, u1, v1);
                vertex(springArray[i+1][j].pos.x, springArray[i+1][j].pos.y, springArray[i+1][j].pos.z, u2, v1);
                vertex(springArray[i][j+1].pos.x, springArray[i][j+1].pos.y, springArray[i][j+1].pos.z, u1, v2);
                vertex(springArray[i+1][j+1].pos.x, springArray[i+1][j+1].pos.y, springArray[i+1][j+1].pos.z, u2, v2);
                endShape();
            }
        }
    }
}

//public Vec3 getRayPoint(float mouse_x, float mouse_y, float depth) {
//    float x = screenX(mouse_x, mouse_y, depth);
//    float y = screenY(mouse_x, mouse_y, depth);
//    float z = screenZ(mouse_x, mouse_y, depth);
//    return new Vec3(x, y, z);
//}

// ... other parts of your code ...

//void mousePressed() {
//    Vec3 nearPoint = getRayPoint(mouseX, mouseY, 0);
//    Vec3 farPoint = getRayPoint(mouseX, mouseY, 1);
//    float minDist = Float.MAX_VALUE;
//    draggedNode = null;
    
//    for (int i = 0; i < threads; i++) {
//        for (int j = 0; j < numBalls; j++) {
//            Node node = springArray[i][j];
//            float distance = node.pos.distanceToLine(nearPoint, farPoint);
//            if (distance < minDist) {
//                minDist = distance;
//                draggedNode = node;
//            }
//        }
//    }
//}

//void mousePressed() {
//    Vec3 nearPoint = getRayPoint(mouseX, mouseY, 0);
//    Vec3 farPoint = getRayPoint(mouseX, mouseY, 1);
//    float minDist = Float.MAX_VALUE;
//    draggedNode = null;
    
//    // Determine the bounds of the cloth
//    Vec3 topLeft = springArray[0][0].pos;
//    Vec3 bottomRight = springArray[threads-1][numBalls-1].pos;
    
//    for (int i = 0; i < threads; i++) {
//        for (int j = 0; j < numBalls; j++) {
//            Node node = springArray[i][j];
//            float distance = node.pos.distanceToLine(nearPoint, farPoint);
            
//            if (distance < minDist) {
//                // Check if the clicked point is within the bounds of the cloth
//                if (node.pos.x >= topLeft.x && node.pos.x <= bottomRight.x && 
//                    node.pos.y >= topLeft.y && node.pos.y <= bottomRight.y && 
//                    node.pos.z >= topLeft.z && node.pos.z <= bottomRight.z) {
//                    minDist = distance;
//                    draggedNode = node;
//                }
//            }
//        }
//    }
//}

//void mouseDragged() {
//    if (draggedNode != null) {
//        Vec3 mouse3D = getRayPoint(mouseX, mouseY, 0.5f);
        
//        // Check if the new position would be inside the sphere
//        float distanceToSphere = mouse3D.distanceTo(spherePosition);
//        if (distanceToSphere <= sphereRadius) {
//            // If it's inside, adjust the position to be on the surface of the sphere
//            Vec3 fromSphereToMouse3D = mouse3D.minus(spherePosition).normalized();
//            mouse3D = spherePosition.plus(fromSphereToMouse3D.times(sphereRadius));
//        }

//        draggedNode.pos.set(mouse3D);
//    }
//}



//void mouseReleased() {
//    draggedNode = null;
//}



void keyPressed() {
  if (key == 'w') spherePosition.y -= keySpeed;
  if (key == 'a') spherePosition.x -= keySpeed;
  if (key == 's') spherePosition.y += keySpeed;
  if (key == 'd') spherePosition.x += keySpeed;
  if (key == 'q') spherePosition.z += keySpeed;
  if (key == 'e') spherePosition.z -= keySpeed;
  if (key == 'r') createCloth();
  if (key == 'f') fixed = !fixed;
  if (key == 'c') windForce.z += 5; 
  if (key == 'v') windForce.z -= 5;  // Decrease wind strength
  if (key == ' ') {
        // Activate the ball
        ballActive = true;

        // Set a random starting position for the ball
        float randomX = random(50, 450);
        float randomY = random(50, 450);
        float randomZ = random(50, 450);
        thrownBall.pos.set(new Vec3(randomX, randomY, randomZ));

        // Set the velocity of the ball to be directed towards the center of the cloth
        Vec3 clothCenter = new Vec3(200 + (restLen * threads)/2, 200, (restLen * numBalls)/2);
        Vec3 directionToCloth = clothCenter.minus(thrownBall.pos).normalized();
        float speed = 200.0; // You can adjust this value as needed
        thrownBall.vel.set(directionToCloth.times(speed));
    }


}
