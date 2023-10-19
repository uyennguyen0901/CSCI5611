class Circle {
    Vec2 position;
    float radius;
    color[] discoColors = {
        color(255, 0, 0),   // Red
        color(0, 255, 0),   // Green
        color(0, 0, 255),   // Blue
        color(255, 255, 0), // Yellow
        color(0, 255, 255), // Cyan
        color(255, 0, 255)  // Magenta
        //... add more colors if you like
    };
    int currentColorIndex = 0;

    Circle(Vec2 pos, float r) {
        position = pos;
        radius = r;
    }

    boolean collidesWithBall(Ball ball) {
        Vec2 ballPos = ball.position;
        float dist = position.distanceTo(ballPos);
        return (dist <= (radius + ball.radius));
    }

    void update(Ball b) {
        if (collidesWithBall(b)) {
            currentColorIndex = (currentColorIndex + 1) % discoColors.length; // Cycle through the colors
        }
    }

    void display() {
        strokeWeight(5);
        fill(discoColors[currentColorIndex]);
        circle(position.x, position.y, radius); // Using diameter for the circle function
    }
}
