class RigidBody{
  float w;
  float h;
  float box_bounce;                       //Coef. of restitution
  
  float mass;                             //Resistance to change in momentum/velocity
  float rot_inertia;                      //Resistance to change in angular momentum/angular velocity
  Vec2 momentum;                          //Speed the box is translating (derivative of position)
  float angular_momentum;                 //Speed the box is rotating (derivative of angle)
  Vec2 center;                            //Current position of center of mass
  Vec2 init_center;
  float angle;                            //Current rotation amount (orientation)
  Vec2 total_force;                       //Forces change position (center of mass)
  float total_torque;                     //Torques change orientation (angle)
  Vec2 p1,p2,p3,p4;                       //4 corners of the box -- computed in updateCornerPositions()
  
  RigidBody(Vec2 c, float w, float h, float bounce){
    this.w = w;
    this.h = h;
    box_bounce = bounce;
    center = c;
    init_center = c;
    angle = 0.0;
    mass = 1;
    rot_inertia = mass*(w*w+h*h)/12;
    momentum = new Vec2(0,0);
    angular_momentum = 0;
    total_force = new Vec2(0,0);
    total_torque = 0;
    updateCornerPositions();
  }
  
  // Physics Functions
  void apply_force(Vec2 force, Vec2 applied_position){
    total_force.add(force);
    Vec2 displacement = applied_position.minus(center);
    total_torque += cross(displacement, force);
  }
  
  void updateCornerPositions(){
    Vec2 right = new Vec2(cos(angle),sin(angle)).times(w/2);
    Vec2 up = new Vec2(-sin(angle),cos(angle)).times(-h/2);
    p1 = center.plus(right).plus(up); // top right
    p2 = center.plus(right).minus(up); // bottom right
    p3 = center.minus(right).plus(up); // top left
    p4 = center.minus(right).minus(up); // bottom left
  }
  
  //Updates momentum & angular_momentum based on collision using an impulse based method
  //This method assumes you hit an immovable obstacle which simplifies the math
  // see Eqn 8-18 of here: https://www.cs.cmu.edu/~baraff/sigcourse/notesd2.pdf
  // or Eqn 9 here: http://www.chrishecker.com/images/e/e7/Gdmphys3.pdf
  //for obstacle-obstacle collisions.
  void resolveCollision(Vec2 hit_point, Vec2 hit_normal){
    center.add(hit_normal.times(1.01));
    Vec2 r = hit_point.minus(center);
    Vec2 r_perp = perpendicular(r);
    Vec2 object_vel = momentum.times(1/mass);
    float object_angular_speed = angular_momentum/rot_inertia;
    Vec2 point_vel = object_vel.plus(r_perp.times(object_angular_speed));
    float j = -(1+box_bounce)*dot(point_vel,hit_normal);
    j /= (1/mass + pow(dot(r_perp,hit_normal),2)/rot_inertia);
   
    Vec2 impulse = hit_normal.times(j);
    momentum.add(impulse);
    angular_momentum += dot(r_perp,impulse);
    updateCornerPositions();
  }
  
  boolean box_box_collision2(RigidBody other) {
    if(center.x < other.center.x + other.w &&
    center.x + w > other.center.x &&
    center.y < other.center.y + other.h &&
    center.y + h > other.center.y)
    {
        System.out.println("Collision Detected");
        return true;
    }
    return false;
  }
  
  ColideInfo box_box_collision(RigidBody other) {
    // Compute the 4 corners of both boxes
    updateCornerPositions();
    other.updateCornerPositions();

    ColideInfo info = new ColideInfo();
    info.hit = false;
    
    Vec2 collisionNormal = null;
    float minOverlap = Float.POSITIVE_INFINITY;

    // Define the edges and normals of both boxes
    Vec2[] edges = {p2.minus(p1), p3.minus(p2), other.p2.minus(other.p1), other.p3.minus(other.p2)};
    Vec2[] normals = {new Vec2(-edges[0].y, edges[0].x), new Vec2(-edges[1].y, edges[1].x), 
                     new Vec2(-edges[2].y, edges[2].x), new Vec2(-edges[3].y, edges[3].x)};

    for (Vec2 normal : normals) {
        float minThis = Float.POSITIVE_INFINITY;
        float maxThis = Float.NEGATIVE_INFINITY;
        float minOther = Float.POSITIVE_INFINITY;
        float maxOther = Float.NEGATIVE_INFINITY;

        for (Vec2 vertex : new Vec2[]{p1, p2, p3, p4}) {
            float projection = dot(vertex, normal);
            minThis = Math.min(minThis, projection);
            maxThis = Math.max(maxThis, projection);
        }

        for (Vec2 vertex : new Vec2[]{other.p1, other.p2, other.p3, other.p4}) {
            float projection = dot(vertex, normal);
            minOther = Math.min(minOther, projection);
            maxOther = Math.max(maxOther, projection);
        }

        // Check for overlap on the current axis
        if (maxThis < minOther || maxOther < minThis) {
            // Separating axis found, no collision
            return info;
        }
        else {
            // Calculate the overlap (penetration) on this axis
            float overlap = Math.min(maxThis, maxOther) - Math.max(minThis, minOther);

            if (overlap < minOverlap) {
                minOverlap = overlap;
                collisionNormal = normal;
            }
        }
    }

    // If no separating axis is found, the boxes are colliding
    info.hit = true;
    Vec2 hitPoint = p1.plus(collisionNormal.times(minOverlap * 0.5));
    info.objectNormal = collisionNormal;
    info.hitPoint = hitPoint;
    
    System.out.println("Collision Detected");
    return info;
  }

  void resolveBoxCollision(RigidBody other, Vec2 hit_point, Vec2 hit_normal){
    Vec2 r = hit_point.minus(center);
    Vec2 r_perp = perpendicular(r);
    Vec2 object_vel = momentum.times(1/mass);
    float object_angular_speed = angular_momentum/rot_inertia;
    Vec2 vAP = object_vel.plus(r_perp.times(object_angular_speed)); //might be incorrect
    
    Vec2 r2 = hit_point.minus(other.center);
    Vec2 r_perp2 = perpendicular(r2);
    Vec2 object_vel2 = other.momentum.times(1/other.mass);
    float object_angular_speed2 = other.angular_momentum/other.rot_inertia;
    Vec2 vBP = object_vel2.plus(r_perp2.times(object_angular_speed2)); //might be incorrect

    Vec2 point_vel = vAP.minus(vBP); //correct

    float j = -(1+box_bounce)*dot(point_vel,hit_normal); //correct
    j /= (dot(hit_normal, hit_normal) * (1/mass + 1/other.mass) + pow(dot(r_perp,hit_normal),2)/rot_inertia + pow(dot(r_perp2,hit_normal),2)/other.rot_inertia);

    Vec2 impulse = hit_normal.times(j);
    momentum.add(impulse);
    angular_momentum += dot(r_perp,impulse)/rot_inertia;
    center.add(hit_normal.times(0.01));

    Vec2 impulse2 = hit_normal.times(-j);
    other.momentum.add(impulse2);
    other.angular_momentum += dot(r_perp2,impulse2)/other.rot_inertia;
    other.center.add(hit_normal.times(-0.01));
    
    updateCornerPositions();
    other.updateCornerPositions();
  }
  
}
