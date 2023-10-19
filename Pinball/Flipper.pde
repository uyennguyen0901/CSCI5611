class Flipper {
    Vec2 position;
    float angle, angularVel;
    //float startAngle;
    //float minAngle, maxAngle;  // Minimum/max rotation angle
    float flipperWidth, flipperHeight;
    PImage img;

    public Flipper(Vec2 pos, float a, PImage img) {
        position = pos;
        angle = radians(a);
        this.img = img;

        //startAngle = a;
        angularVel = 0;
        //minAngle = startAngle - PI/4;  // 10 degrees backward rotation
        //maxAngle = startAngle + PI/4;
        flipperWidth = 80;
        flipperHeight = 80;
    }

    Vec2 getTip() {  // Calculate the tip based on the current angle and the length of the flipper
        float tipX = position.x + 40 * sin(angle);
        float tipY = position.y - 45 * cos(angle);

        Vec2 tip = new Vec2(tipX, tipY);

        return tip;
    }

    Vec2 getEnd() {
        float endX = position.x - 40 * sin(angle);    // Gets the end point of flipper
        float endY = position.y + 45 * cos(angle);

        Vec2 end = new Vec2(endX, endY);

        return end;
    }

    void update() {
        if (angle <= 120 && angle >= radians(45)) {      // Left flipper movement
            angle += angularVel;
        }

        if (angle >= -120 && angle <= radians(-45)) {    // Right flipper movement
            angle += angularVel;
        }
    }

    void display() {
        pushMatrix();
        translate(position.x, position.y);
        rotate(angle);
        scale(0.3);
        imageMode(CENTER);
        image(img, 0, 0);
        popMatrix();
    }
}
