class Ball {
    Vec2 position;
    Vec2 velocity;
    float radius;                     // Adjust as needed

    Vec2 gravity = new Vec2(0, 400);  // Variables that affect velocity
    float dampen = 0.7;

    Ball(Vec2 pos) {
        position = pos;
        velocity = new Vec2(0, 0); // Starting velocity is 0
        radius = 14;
    }

    void update(float dt) {
        velocity.add(gravity.times(dt));
        position.add(velocity.times(dt));
    }

    void display() {
        fill(255);
        strokeWeight(1);
        circle(position.x, position.y, radius);
    }

    void applyForce(Vec2 f) {
        velocity.add(f);
    }

    boolean collidesWithWall(Vec2 p1, Vec2 p2) {
        Vec2 toBallCenter = position.minus(p1);      // Vector to ball center
        Vec2 wall = p2.minus(p1);                    // wall segment vector

        float a = 1;
        float b = -2.0 * dot(wall.normalized(), toBallCenter);
        float c = (toBallCenter.x * toBallCenter.x) + (toBallCenter.y * toBallCenter.y) - (radius * radius);

        float d = b*b - (4*a*c);    // using quadratic formula to find collision;
        // if discriminant d >= 0 && 0 < root < walllength then collision exists.
        if (d >= 0) {
            float root = ((-1.0*b)-sqrt(d)) / (2.0 * a);
            return (root > 0 && root < wall.length());
        }
        return false;
    }

    boolean collidesWithCircle(Circle circle) {
        Vec2 circlePos = circle.position;
        float dist = position.distanceTo(circlePos) + 25;
        return (dist <= (radius + circle.radius));
    }

    boolean collidesWithFlipper(Flipper f) {
        Vec2 tip = f.getTip();
        Vec2 end = f.getEnd();

        if (this.collidesWithWall(tip, end)) {
            return true;
        }
        return false;
    }

    boolean collidesWithPlunger(Plunger p) {
        Vec2 plungerTopLeft = new Vec2(p.position.x-12, p.position.y-10);      // Plunger topLeft Bound
        Vec2 plungerTopRight = new Vec2(p.position.x+21, p.position.y-10);     // Plunger topRight Bound

        if (this.collidesWithWall(plungerTopLeft, plungerTopRight)) {
            return true;
        }
        return false;
    }

    void handleWallCollision(Vec2 p1, Vec2 p2) {
        Vec2 toBallCenter = position.minus(p1);      // vector from p1 to ball's center
        Vec2 wall = p2.minus(p1);                    // vector from p1 to p2

        float projMag = dot(toBallCenter, wall) / (wall.length()*wall.length());  // Projection vector; gives the closest point
        Vec2 proj = p1.plus(wall.times(projMag));                                  // on the wall to the ball's center

        Vec2 norm = (proj.minus(position)).normalized();          // Calculate reflection vector

        float reflectionMag = dot(velocity, norm);
        Vec2 reflection = norm.times(2 * reflectionMag);

        velocity.subtract(reflection.times(dampen));

        float dist = position.distanceTo(proj)-6;    // -6 offset due to ball and wall strokeWeight
        if (dist <= radius) {        // Repositions ball when intersecting wall
            position.subtract(norm);
        }
    }

    void handleCircleCollision(Circle circle) {
        Vec2 norm = (position.minus(circle.position)).normalized();

        float reflectionMag = dot(velocity, norm);
        Vec2 reflection = norm.times(2 * reflectionMag);

        velocity.subtract(reflection.times(dampen));

        float dist = position.distanceTo(circle.position)+25;  // 25 offset due to ball and circle strokeWeight
        float radiusSum = radius+circle.radius;
        if (dist < radiusSum) {
            position.add(norm.times(radiusSum-dist));        // Repositions ball from circles
        }
    }

    void handlePlungerCollision(Plunger p) {
        if (position.y > p.position.y - radius) {      // Collision check for top of plunger
            position.y = p.position.y - radius;
            velocity.y *= dampen;
        }
    }

    void handleFlipperCollision(Flipper f) {
        Vec2 tip = f.getTip();
        Vec2 end = f.getEnd();

        this.handleWallCollision(tip, end);
    }

    boolean isOutOfBounds() {
        return position.x+radius+5 < 0 || position.x-radius-5 > width || position.y+radius+5 < 0 || position.y-radius-5 > height;
    }
}
