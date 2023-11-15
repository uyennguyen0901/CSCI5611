float theta = 0.0;
float skinTone_R = 218;
float skinTone_G = 167;
float skinTone_B = 116;
float rotationSpeed = 2.9;//Rotation speed (line 88)
Vec2 root = new Vec2(135,185);

float a0 = 0.3;
float l0 = 30;
float a1 = 0.3;
float l1 = 30;
float a2 = 0.3;
float l2 = 20;
float a0_left = 0.3;
float a1_left = 0.3;
float a2_left = 0.3;
float armW = 20;
float maxChange = 0.05;
float shoulderOffset = 30;
float lastDraggedXR;
float lastDraggedYR;
float lastDraggedXL;
float lastDraggedYL;
boolean click;
boolean lgrabbed1, rgrabbed1, lrgrabbed1, rrgrabbed1;
boolean lgrabbed2, rgrabbed2, lrgrabbed2, rrgrabbed2;
float foot0 = 35; // Upper foot length
float foot1 = 25; // Lower foot length
float foot2 = 10; // Toes length

// Feet segment angles, similar to arm angles
 float f0 = 1.5;
 float f1 = 0.3;
 float f2 = 0.3;

// Feet root positions, similar to arm roots
Vec2 footRootR = new Vec2(135, 245); // Right foot root position
Vec2 footRootL = new Vec2(135, 185); // Left foot root position

// Feet segment widths, similar to arm width
float footW = 15;
Vec2 start_l1,start_l2,endPoint;
Vec2 start_l1_left,start_l2_left,endPoint_left;
Vec2 obstacle1 = new Vec2(100,220);
Vec2 obstacle2 = new Vec2(180,220);
void fk_right() {
    start_l1 = new Vec2(cos(a0)*l0,sin(a0)*l0).plus(root);
    start_l2 = new Vec2(cos(a0+a1)*l1,sin(a0+a1)*l1).plus(start_l1);
    endPoint = new Vec2(cos(a0+a1+a2)*l2,sin(a0+a1+a2)*l2).plus(start_l2);
}
void fk_left() {
    // Calculate positions for left arm joints
    start_l1_left = new Vec2(cos(a0_left) * l0, sin(a0_left) * l0).plus(root);
    start_l2_left = new Vec2(cos(a0_left + a1_left) * l1, sin(a0_left + a1_left) * l1).plus(start_l1_left);
    endPoint_left = new Vec2(cos(a0_left + a1_left + a2_left) * l2, sin(a0_left + a1_left + a2_left) * l2).plus(start_l2_left);
}
//===================Solve function for right arm ===================================

void solve() {
    //Vec2 goal = new Vec2(lastDraggedXR, lastDraggedYR);
    Vec2 goal = new Vec2(mouseX, mouseY);
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;

    //Update wrist joint
    startToGoal = goal.minus(start_l2);
    startToEndEffector = endPoint.minus(start_l2);
    dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
    dotProd = clamp(dotProd,-1,1);
    angleDiff = acos(dotProd);
    
    float old_a2 = a2;
    do {
        if (abs(angleDiff) < 0.00005) { // Adjusted threshold
            break;
        }
        a2 = old_a2;
        if (cross(startToGoal, startToEndEffector) < 0)
            a2 += angleDiff;
        else
            a2 -= angleDiff;
        a2 = constrain(a2, a1 - PI/2, a1 + PI/2); // Wrist joint limits
        fk_right(); // Update link positions with fk
        angleDiff *= 0.5; // Shrink angle difference
        println("right wrist collide with object");
    } while (checkArmCircleCollisionR(180, 220, 15));
    //updateJointWithCollision(a0, angleDiff, startToGoal, startToEndEffector, 0, PI/2, "Shoulder");

    // Update elbow joint
    startToGoal = goal.minus(start_l1);
    startToEndEffector = endPoint.minus(start_l1);
    dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
    dotProd = clamp(dotProd, -1, 1);
    angleDiff = acos(dotProd);
    float old_a1 = a1;
    do {
      if (abs(angleDiff) < 0.00005) { // Adjusted threshold
            break;
        }
        a1 = old_a1;
        if (cross(startToGoal, startToEndEffector) < 0)
            a1 += angleDiff;
        else
            a1 -= angleDiff;
        // Add elbow joint limits here if necessary
        fk_right(); // Update link positions with fk
        angleDiff *= 0.5; // Shrink angle difference
        println("right elbow collide with object");
    } while (checkArmCircleCollisionR(180, 220, 15));
    //updateJointWithCollision(a1, angleDiff, startToGoal, startToEndEffector, -PI, PI, "Elbow");

    // Update Shouder joint
    startToGoal = goal.minus(root);
    if (startToGoal.length() < .0001) return;
    startToEndEffector = endPoint.minus(root);
    dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
    dotProd = clamp(dotProd,-1,1);
    angleDiff = acos(dotProd);
    float old_a0 = a0;
    do {
      if (abs(angleDiff) < 0.00005) { // Adjusted threshold
            break;
        }
        a0 = old_a0;
        if (cross(startToGoal, startToEndEffector) < 0)
            a0 += angleDiff;
        else
            a0 -= angleDiff;
        a0 = constrain(a0, 0, PI/2); // Shoulder joint limits
        fk_right(); // Update link positions with fk
        angleDiff *= 0.5; // Shrink angle difference
        println("right shoulder collide with object");
    } while (checkArmCircleCollisionR(180, 220, 15));
    //updateJointWithCollision(a2, angleDiff, startToGoal, startToEndEffector, a1 - PI/2, a1 + PI/2, "Wrist");

    println("Angle 0:", a0, "Angle 1:", a1, "Angle 2:", a2);
}

void updateJointWithCollision(float jointAngle, float angleDiff, Vec2 startToGoal, Vec2 startToEndEffector, float minAngle, float maxAngle, String jointName) {
    float old_angle;
    do {
        old_angle = jointAngle;
        if (cross(startToGoal, startToEndEffector) < 0) {
            jointAngle += angleDiff;
        } else {
            jointAngle -= angleDiff;
        }
        jointAngle = constrain(jointAngle, minAngle, maxAngle);
        fk_right();
        angleDiff *= 0.5;
        if (abs(angleDiff) < 0.01) {
            break;
        }
    } while (checkArmCircleCollisionR(180, 220, 15));

    if (old_angle != jointAngle) {
        println(jointName + " joint adjusted to avoid collision");
    }
}





//===================Solve function for left arm ===================================
void solve_left() {
    //Vec2 goal = new Vec2(lastDraggedXL, lastDraggedYL);
    Vec2 goal = new Vec2(mouseX, mouseY);
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;

    // Update wrist joint for left arm
    startToGoal = goal.minus(start_l2_left);
    startToEndEffector = endPoint_left.minus(start_l2_left);
    dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
    dotProd = clamp(dotProd, -1, 1);
    angleDiff = acos(dotProd);
    //float old_a2 = a2;
    //do {
        //if (abs(angleDiff) < 0.00005) { // Adjusted threshold
        //    break;
        //}
       // a2 = old_a2;
        if (cross(startToGoal, startToEndEffector) < 0)
            a2_left += angleDiff;
        else
            a2_left -= angleDiff;
        // TODO: Wrist joint limits for left arm
        a2_left = constrain(a2_left, a1_left - PI / 2, a1_left + PI / 2);
        fk_left(); // Update link positions with fk for left arm
        //angleDiff *= 0.5; 
        //} while (checkArmCircleCollisionR(180, 220, 15));

    // Update elbow joint for left arm
    startToGoal = goal.minus(start_l1_left);
    startToEndEffector = endPoint_left.minus(start_l1_left);
    dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
    dotProd = clamp(dotProd, -1, 1);
    angleDiff = acos(dotProd);
    //float old_a1 = a1;
    //do {
    //  if (abs(angleDiff) < 0.00005) { // Adjusted threshold
    //        break;
    //    }
    //    a1 = old_a1;
        if (cross(startToGoal, startToEndEffector) < 0)
            a1_left += angleDiff;
        else
            a1_left -= angleDiff;
        fk_left(); // Update link positions with fk for left arm
    //    angleDiff *= 0.5; 
    //} while (checkArmCircleCollisionR(180, 220, 15));
    // Update shoulder joint for left arm
    startToGoal = goal.minus(root); // Note: The root is the same for both arms
    if (startToGoal.length() < .0001) return;
    startToEndEffector = endPoint_left.minus(root);
    dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
    dotProd = clamp(dotProd, -1, 1);
    angleDiff = acos(dotProd);
    // float old_a0 = a0;
    //do {
    //  if (abs(angleDiff) < 0.00005) { // Adjusted threshold
    //        break;
    //    }
    //    a0 = old_a0;
        if (cross(startToGoal, startToEndEffector) < 0)
            a0_left += angleDiff;
        else
            a0_left -= angleDiff;
        // TODO: Shoulder joint limits for left arm
        
        
        a0_left = constrain(a0_left,-3*PI/2, -PI);
        fk_left(); // Update link positions with fk for left arm
    //  angleDiff *= 0.5; // Shrink angle difference
        
    //} while (checkArmCircleCollisionR(180, 220, 15));
    //println("Left Angle 0:", a0_left, "Left Angle 1:", a1_left, "Left Angle 2:", a2_left);
}

void setup() {
    size(800,600);
}

void draw () {
    fk_right();
    fk_left();
    solve();
    solve_left();
    
    //updateRoot();
    background(250);//Colorful background
    
    //draw floor
    push();
    Floor(0,355,width,85);
    pop();
    // draw witch
    Witch(50,50);
    drawCircle(180, 220, 15, color(100, 150, 200));
    //draw circle 
    fill(121,121,144);
    circle(obstacle1.x, obstacle1.y,25);
    circle(obstacle2.x, obstacle2.y, 25);
    
    // grabbing Obstacles 1
    float ldist1 = obstacle1.minus(endPoint_left).length();
    float rdist1 = obstacle1.minus(endPoint).length();
    Vec2 m1 = new Vec2(mouseX, mouseY);
    float lrdist1 = m1.minus(root).length();
    float rrdist1 = m1.minus(root).length();
    if (click) {
    if (ldist1 < 10) {
      lgrabbed1 = true;
    }
    if (lgrabbed1 && ldist1 < rdist1) {
      obstacle1.x = endPoint_left.x;
      obstacle1.y = endPoint_left.y;
    }
    if (rdist1 < 10) {
      rgrabbed1 = true;
    }
    if (rgrabbed1 && rdist1 < ldist1) {
      obstacle1.x = endPoint.x;
      obstacle1.y = endPoint.y;
    }

    if (lrdist1 < 10) {
      lrgrabbed1 = true;
    }
    //if (lrgrabbed) {
    //  root = new Vec2(m1.x, m1.y);
    //}
    if (rrdist1 < 10) {
      rrgrabbed1 = true;
    }
    //if (rrgrabbed) {
    //  root = new Vec2(m1.x, m1.y);
    //}
  }
  //grabbing obstacles 2
    float ldist2 = obstacle2.minus(endPoint_left).length();
    float rdist2 = obstacle2.minus(endPoint).length();
    Vec2 m2 = new Vec2(mouseX, mouseY);
    float lrdist2 = m2.minus(root).length();
    float rrdist2 = m2.minus(root).length();
    if (click) {
    if (ldist2 < 10) {
      lgrabbed2 = true;
    }
    if (lgrabbed2 && ldist2 < rdist2) {
      obstacle2.x = endPoint_left.x;
      obstacle2.y = endPoint_left.y;
    }
    if (rdist2 < 10) {
      rgrabbed2 = true;
    }
    if (rgrabbed2 && rdist2 < ldist2) {
      obstacle2.x = endPoint.x;
      obstacle2.y = endPoint.y;
    }

    if (lrdist2 < 10) {
      lrgrabbed2 = true;
    }
    //if (lrgrabbed) {
    //  root = new Vec2(m2.x, m2.y);
    //}
    if (rrdist2 < 10) {
      rrgrabbed2 = true;
    }
    //if (rrgrabbed) {
    //  root = new Vec2(m2.x, m2.y);
    //}
  }
  if (!click) {
    lgrabbed1 = false;
    rgrabbed1 = false;
    lrgrabbed1 = false;
    rrgrabbed1 = false;
    lgrabbed2 = false;
    rgrabbed2 = false;
    lrgrabbed2 = false;
    rrgrabbed2 = false;
  }
    
}

//========================================Witch=================================================================
void Witch(float positionX,float positionY) {
    noStroke();//Removes the strokes
    translate(positionX,positionY);//Translates witch
    Hair(120,170,110,140,0);//Calls Hair function (line 115)
    //Legs(102.5,240,15,60,153,153,255);//Calls Legs function (line 120)
    //Feet(110,300,15,15,0);//Calls Feet function (line 97) (line 127)
    drawFootR(footW, skinTone_R, skinTone_G, skinTone_B);
    drawFootL(footW, skinTone_R, skinTone_G, skinTone_B);
    //drawFootL(footW, skinTone_R, skinTone_G, skinTone_B);
    //Arms(90,200,15,100,skinTone_R,skinTone_G,skinTone_B,45);//Calls Arms function (line 133)
    Neck(110,160,20,40,skinTone_R,skinTone_G,skinTone_B);//Calls Neck function (line 153)
    Dress(100,180,10,20,94,0,216);//Calls Dress function (line 159)
    //Dress(40, 60, 94, 0, 216); // Example call with dress width 40, height 60, and color RGB(94, 0, 216)

    ArmsR(15,skinTone_R,skinTone_G,skinTone_B,45);//Calls Arms function (line 133)
    ArmsL(15,skinTone_R,skinTone_G,skinTone_B,45);
    Head(120,140,80,70.5,skinTone_R,skinTone_G,skinTone_B);//Calls Head function (line 171)
    Fringe(90,110,0);//Calls Fringe function (line 177)
    Eyes(100,140,15,15,255);//Calls Eyes function (line 183)
    Iris(102,138.5,10,10,0);//Calls Iris function (line 189)
    Highlight(103,137,4,4,255);//Calls Highlight function (line 195)
    Cheeks(100,152,14,3.5,255,102,102);//Calls Cheeks function (line 201)
    Hat(120,110,100,20,94,0,216);//Calls Hat function (line 208)
    Nose(120,150,7.5,6,0);//Calls Nose function (line 215)
    Mouth(120,162.5,4,7,0);//Calls Mouth function (line 221)

}

//WITCH FUNCTIONS
void Hair(float positionX,float positionY,float characterWidth,float characterHeight, float characterColor) {
//Hair
    fill(characterColor);//hair color
    ellipse(positionX,positionY,characterWidth,characterHeight);//hair shape
}
void Legs(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor_R,
          float characterColor_G,float characterColor_B) {
//Legs
    fill(characterColor_R,characterColor_G,characterColor_B);//Pants color
    rect(positionX, positionY,characterWidth, characterHeight);//Right Leg shape
    rect(positionX+20, positionY,characterWidth, characterHeight);//Left Leg shape
}
void Feet(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor) {
//Feet
    fill(characterColor);//Shoes color
    ellipse(positionX, positionY,characterWidth, characterHeight);//Right Foot shape
    ellipse(positionX+20, positionY,characterWidth, characterHeight);//Left Foot shape
}
void drawFootR(float characterWidth, float characterColor_R, float characterColor_G, float characterColor_B) {
    // Right Foot
   
    pushMatrix();
    fill(characterColor_R, characterColor_G, characterColor_B);
    translate(footRootR.x, footRootR.y);
    rotate(f0);
    rect(0, -footW/2, foot0, characterWidth); // Upper foot
    popMatrix();

    pushMatrix();
    translate(footRootR.x + cos(f0) * foot0, footRootR.y + sin(f0) * foot0); // Adjust position for lower foot
    rotate(f0 + f1);
    rect(0, -footW/2, foot1, characterWidth); // Lower foot
    popMatrix();

    pushMatrix();
    translate(footRootR.x + cos(f0) * foot0 + cos(f0 + f1) * foot1, footRootR.y + sin(f0) * foot0 + sin(f0 + f1) * foot1); // Adjust position for toes
    rotate(f0 + f1 + f2);
    rect(0, -footW/2, foot2, characterWidth); // Toes
    popMatrix();
}
void drawFootL(float characterWidth, float characterColor_R, float characterColor_G, float characterColor_B) {
    // Right Foot
    pushMatrix();
    fill(characterColor_R, characterColor_G, characterColor_B);
    translate(footRootR.x-30, footRootR.y);
    rotate(f0);
    rect(0, -footW/2, foot0, characterWidth); // Upper foot
    popMatrix();

    pushMatrix();
    translate(footRootR.x-30 + cos(f0) * foot0, footRootR.y + sin(f0) * foot0); // Adjust position for lower foot
    rotate(f0 + f1);
    rect(0, -footW/2, foot1, characterWidth); // Lower foot
    popMatrix();

    pushMatrix();
    translate(footRootR.x-30 + cos(f0) * foot0 + cos(f0 + f1) * foot1, footRootR.y + sin(f0) * foot0 + sin(f0 + f1) * foot1); // Adjust position for toes
    rotate(f0 + f1 + f2);
    rect(0, -footW/2, foot2, characterWidth); // Toes
    popMatrix();
}
//============================Arm========================================
void ArmsR(float characterWidth,float characterColor_R,
          float characterColor_G,float characterColor_B,float ArmRotation) {
    //Arms

    //Right Arm
    pushMatrix();
    fill(characterColor_R,characterColor_G,characterColor_B);//SkinTone/R_Arm color
    translate(root.x, root.y );
    rotate(a0);//Rotates R_Arm
    rect(0, -armW/2,l0, characterWidth);//R_arm shape
    popMatrix();
    pushMatrix();
    translate(start_l1.x,start_l1.y);
    rotate(a0+a1);
    rect(0, -armW/2,l1, characterWidth);
    popMatrix();
    pushMatrix();
    translate(start_l2.x,start_l2.y);
    rotate(a0+a1+a2);
    rect(0, -armW/2,l2, characterWidth);
    popMatrix();
}
void ArmsL(float characterWidth,float characterColor_R,
          float characterColor_G,float characterColor_B,float ArmRotation) {
    //Left Arm
    //++++++causing issue ++++++
    pushMatrix();
    fill(characterColor_R,characterColor_G,characterColor_B);
    translate(root.x - shoulderOffset, root.y); // Move the left arm to the left shoulder
    rotate(a0_left); // Invert the rotation for the left arm
    rect(0, -armW / 2, l0, characterWidth); // Draw the upper arm
    popMatrix();
 
    pushMatrix();
    translate(start_l1_left.x - shoulderOffset, start_l1_left.y); // Adjust the x-coordinate for the lower arm
    rotate((a0_left + a1_left)); // Invert the rotation for the left arm
    rect(0, -armW / 2, l1, characterWidth); // Draw the lower arm
    popMatrix();

    pushMatrix();
    translate(start_l2_left.x - shoulderOffset, start_l2_left.y); // Adjust the x-coordinate for the hand
    rotate((a0_left + a1_left + a2_left)); // Invert the rotation for the left arm
    rect(0, -armW / 2, l2, characterWidth); // Draw the hand
    popMatrix();
    


}

//=================================================================================================
void Neck(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor_R,
          float characterColor_G,float characterColor_B) {
    //Neck
    fill(characterColor_R,characterColor_G,characterColor_B);//SkinTone/Neck color
    rect(positionX, positionY,characterWidth,characterHeight);//Neck shape
}
void Dress(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor_R,
           float characterColor_G,float characterColor_B) {
    //Dress
    fill(characterColor_R,characterColor_G,characterColor_B);//Dress color
    //Dress "staps"
    rect(positionX, positionY,characterWidth,characterHeight);//Right Strap shape
    rect(positionX+30, positionY,characterWidth,characterHeight);//Left Strap shape
    //Dress "body"
    rect(positionX,positionY+15,characterWidth+30,characterHeight+5);//Top part shape
    quad(positionX,positionY+40,positionX+40,positionY+40,positionX+50,positionY+70,
         positionX-10,positionY+70);//Bottom part shape
}


void Head(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor_R,
          float characterColor_G,float characterColor_B) {
    //Head
    fill(characterColor_R,characterColor_G,characterColor_B);//SkinTone/Head color
    ellipse(positionX, positionY,characterWidth,characterHeight);//Head shape
}
void Fringe(float positionX,float positionY,float characterColor) {
    //Fringe
    fill(characterColor);//Fringe color
    quad(positionX,positionY,positionX+60,positionY,positionX+70,positionY+20,
         positionX-10,positionY+20);//Fringe shape
}
void Eyes(float positionX,float positionY,float characterWidth,float characterHeight,float characterColor) {
    //Eyes
    fill(characterColor);//Eyes color
    ellipse(positionX,positionY,characterWidth,characterHeight);//Right eye shape
    ellipse(positionX+40,positionY,characterWidth,characterHeight);//Left eye shape
}
void Iris(float positionX,float positionY, float characterWidth,float characterHeight,float characterColor) {
    //Iris
    fill(characterColor);//Iris color
    ellipse(positionX,positionY,characterWidth,characterHeight);//Right iris shape
    ellipse(positionX+40,positionY,characterWidth,characterHeight);//Left iris shape
}
void Highlight(float positionX,float positionY,float characterWidth,float characterHeight,float characterColor) {
//Highlight of the eyes
    fill(characterColor);//Highlight of the eyes color
    ellipse(positionX,positionY,characterWidth,characterHeight);//Right Highlight shape
    ellipse(positionX+40,positionY,characterWidth,characterHeight);//Left Highlight shape
}
void Cheeks(float positionX, float positionY,float characterWidth,float characterHeight,float characterColor_R,
            float characterColor_G,float characterColor_B) {
    //Cheeks
    fill(characterColor_R,characterColor_G,characterColor_B);//Cheeks color
    ellipse(positionX, positionY,characterWidth,characterHeight);//Right cheek shape
    ellipse(positionX+40,positionY,characterWidth,characterHeight);//Left cheek shape
}
void Hat(float positionX,float  positionY,float characterWidth,float characterHeight,float characterColor_R,
         float characterColor_G,float characterColor_B) {
    //Hat
    fill(characterColor_R,characterColor_G,characterColor_B);//Hat color
    triangle(positionX-30,positionY,positionX,positionY-70,positionX+30,positionY);//Top part shape
    ellipse(positionX, positionY,characterWidth,characterHeight);//Bottom part shape
}
void Nose(float positionX,float positionY,float characterWidth,float characterHeight,float characterColor) {
    //nose
    noFill();
    stroke(characterColor);//Nose stroke color
    ellipse(positionX,positionY,characterWidth,characterHeight);//Nose shape
}
void Mouth(float positionX,float positionY,float characterWidth,float characterHeight,float characterColor) { //mouth
    fill(characterColor);//Mouth color
    ellipse(positionX,positionY,characterWidth,characterHeight);//Mouth shape
}



//==============================Floor=====================================================================
void Floor(float posX,float posY,float floorWidth,float floorHeight) {
    noStroke();//Removes stroke
    fill(12);
    rect(posX,posY,floorWidth,floorHeight);//Floor shape
}


boolean rectCircleCollision(float rectX, float rectY, float rectAngle, float rectWidth, float rectHeight, float circleX, float circleY, float circleRadius) {
    // Transform circle center to the rectangle's coordinate space
    float sinA = sin(-rectAngle);
    float cosA = cos(-rectAngle);
    float dx = circleX - rectX;
    float dy = circleY - rectY;
    float xNew = dx * cosA - dy * sinA;
    float yNew = dx * sinA + dy * cosA;

    // Check if the transformed circle center is within the rectangle bounds (expanded by the circle radius)
    return abs(xNew) <= (rectWidth / 2 + circleRadius) && abs(yNew) <= (rectHeight / 2 + circleRadius);
}

boolean checkArmCircleCollision(float circleX, float circleY, float circleRadius) {
    // Check collision for each segment of the arm
    if (rectCircleCollision(root.x - shoulderOffset, root.y, a0_left, l0, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    if (rectCircleCollision(start_l1_left.x - shoulderOffset, start_l1_left.y, a0_left + a1_left, l1, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    if (rectCircleCollision(start_l2_left.x - shoulderOffset, start_l2_left.y, a0_left + a1_left + a2_left, l2, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    return false;
}
boolean checkArmCircleCollisionR(float circleX, float circleY, float circleRadius) {
    // Check collision for each segment of the arm
    if (rectCircleCollision(root.x , root.y, a0, l0, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    if (rectCircleCollision(start_l1.x , start_l1.y, a0 + a1, l1, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    if (rectCircleCollision(start_l2.x , start_l2.y, a0 + a1 + a2, l2, armW, circleX, circleY, circleRadius)) {
        return true;
    }
    return false;
}


boolean isCircleVisible = true;

void drawCircle(float x, float y, float radius, int fillColor) {
    if (isCircleVisible) {
        fill(fillColor);
        noStroke();
        ellipse(x, y, radius * 2, radius * 2);
    }
}
void keyPressed() {
  
    if (key =='c'){
      isCircleVisible = !isCircleVisible;
    }
}

void mousePressed() {
  click = true;
}

void mouseReleased() {
click = false;
}
float rootMovementFactor = 0.05; // Adjust for sensitivity

boolean isLeftFootPlanted = true; // Initial state with left foot as root
Vec2 leftFootTarget; // Target position for the left foot when swinging
Vec2 rightFootTarget; // Target position for the right foot when swinging

//void updateRoot() {
//    float interpolationFactor = 0.05; // Adjust this for smoother or faster movement

//    Vec2 targetRootPos;
//    if (isLeftFootPlanted) {
//        targetRootPos = footRootL;
//        // Check if the right foot has reached its target
//        if (rightFootHasReachedTarget()) {
//            isLeftFootPlanted = false;
//            // Update leftFootTarget for the next step
//        }
//    } else {
//        targetRootPos = footRootR;
//        // Check if the left foot has reached its target
//        if (leftFootHasReachedTarget()) {
//            isLeftFootPlanted = true;
//            // Update rightFootTarget for the next step
//        }
//    }

//    // Smoothly interpolate the root position towards the target position
//    root.x += (targetRootPos.x - root.x) * interpolationFactor;
//    root.y += (targetRootPos.y - root.y) * interpolationFactor;
//}

//boolean leftFootHasReachedTarget() {
//    // Check if footRootL or leftFootTarget is null
//    if (footRootL == null || leftFootTarget == null) {
//        return false; // Cannot calculate distance, return false
//    }

//    float tolerance = 5.0; // Example tolerance value
//    // Manually calculate the distance between footRootL and leftFootTarget
//    float dx = footRootL.x - leftFootTarget.x;
//    float dy = footRootL.y - leftFootTarget.y;
//    float distance = sqrt(dx * dx + dy * dy);

//    return distance < tolerance;
//}


//boolean rightFootHasReachedTarget() {
//    // Check if footRootR or rightFootTarget is null
//    if (footRootR == null || rightFootTarget == null) {
//        return false; // Cannot calculate distance, return false
//    }

//    float tolerance = 5.0; // Example tolerance value
//    // Manually calculate the distance between footRootR and rightFootTarget
//    float dx = footRootR.x - rightFootTarget.x;
//    float dy = footRootR.y - rightFootTarget.y;
//    float distance = sqrt(dx * dx + dy * dy);

//    return distance < tolerance;
//}
