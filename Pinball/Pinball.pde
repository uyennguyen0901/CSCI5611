import processing.sound.*;
PImage bgImage;
PImage flipperImg;
PImage plungerImg;
float flipperX;
float flipperY;
Game game;          // This file has the "interactive" objects.
Ball ball;
Plunger plunger;
//Circle[] circles;
ArrayList<Circle> circles = new ArrayList<Circle>();
Flipper[] flippers;
ParticleSystem fireworks;
SoundFile wallCollisionSound;
SoundFile ballCollisionSound;
//SoundFile flipperSoundFile;
boolean leftFlipperCheck = false;      // flipper collision checks
boolean rightFlipperCheck = false;

void setup() {
    size(400, 700);
    background(31, 38, 26);
    bgImage = loadImage("bg.JPG");
    game = new Game(this);
    wallCollisionSound = new SoundFile(this, "collision.mp3");
    ballCollisionSound = new SoundFile(this, "ballCollision.mp3");
    //SoundFile flipperSoundFile = new SoundFile(this, "flipper.mp3");
    Vec2 startPosition = new Vec2(80, 540);
    ball = new Ball(startPosition);

    flipperImg = loadImage("flipper.png");
    flippers = new Flipper[2];
    flippers[0] = new Flipper(new Vec2(135, 565), 120, flipperImg);
    flippers[1] = new Flipper(new Vec2(250, 565), -120, flipperImg);
    plungerImg = loadImage("plunger.png");
    plunger = new Plunger(new Vec2(75, 590), plungerImg,"spring.mp3", this);
    //==================Comment this for load
    //circles = new Circle[3];
    //circles[0] = new Circle(new Vec2(125, 200), 55);
    //circles[1] = new Circle(new Vec2(250, 200), 55);
    //circles[2] = new Circle(new Vec2(187.5, 300), 55);
    loadScene("scene1.txt");
}

void draw() {
    float dt = 1.0/frameRate;    // Base dt off of frame rate
    background(31, 38, 26);
    


    if (!game.gameStarted) {
        game.displayStartPrompt();
    } else if(ball.isOutOfBounds()) {
        game.gameOver = true;
        game.displayEndPrompt();
    } else {
        image(bgImage, 200, 400, width, height);
        fill(255, 0, 0);
        for (int i = 0; i < flippers.length; i++) {
            flippers[i].update();
            flippers[i].display();
        }

        for (Circle circle : circles) {
            circle.display();
            circle.update(ball);
        }

        plunger.update(dt);
        plunger.display();
        if (fireworks != null) {
            fireworks.run();
        }
        game.update();
        game.display();

        ball.update(dt);
        ball.display();

        checkCollisions(game);
    }
}

void checkCollisions(Game g) {
    TableOutline t = g.tableOutline;

    for (int i=0; i < t.tablePos.length; i++) {
        Vec2 p1 = t.tablePos[i].p1;
        Vec2 p2 = t.tablePos[i].p2;

        if (ball.collidesWithWall(p1, p2)) {
            ball.handleWallCollision(p1, p2);
            wallCollisionSound.play();
        }
    }

    for (Circle circle : circles) {
        if(ball.collidesWithCircle(circle)) {
            ball.handleCircleCollision(circle);
            ballCollisionSound.play();
            g.updateScore(10);
        }
    }

    for (int i=0; i < flippers.length; i++) {
        if (ball.collidesWithFlipper(flippers[i])) {
            ball.handleFlipperCollision(flippers[i]);
            ballCollisionSound.play();
            if (i == 0) {
                leftFlipperCheck = true;
            } else if (i == 1) {
                rightFlipperCheck = true;
            }
        }
    }

    if (ball.collidesWithPlunger(plunger)) {
        ball.handlePlungerCollision(plunger);
        //ballCollisionSound.play();
    }
}

void keyPressed() {
    float forceMultiplier = -700;
    if (keyCode == LEFT) {
        flippers[0].angularVel = radians(-30);  // rotates the left flipper counter-clockwise by 30 rad

        if (leftFlipperCheck) {
            ball.applyForce(new Vec2(0, forceMultiplier));
            leftFlipperCheck = false;
        }
    }
    if (keyCode == RIGHT) {
        flippers[1].angularVel = radians(30);  // rotates the right flipper clockwise by 30 rad

        if (rightFlipperCheck) {
            ball.applyForce(new Vec2(0, forceMultiplier).times(0.9));
            rightFlipperCheck = false;
        }
    }
    if (keyCode == '1') {
        loadScene("scene1.txt");
    }
    if (keyCode == '2') {
        loadScene("scene2.txt");
    }
}

void keyReleased() {            // Resets flipper positions
    if (keyCode == LEFT) {
        flippers[0].angle = radians(120);
        flippers[0].angularVel = 0;
    }
    if (keyCode == RIGHT) {
        flippers[1].angle = radians(-120);
        flippers[1].angularVel = 0;
    }
}

void mousePressed() {
    if (game.checkStartClicked()) {
        game.gameStarted = true;
    } else if(game.checkRestartClicked()) {
        game.gameOver = false;
        game.gameStarted = false;
        game.score = 0;
        ball.position = new Vec2(80, 540);
    } else {
        plunger.pull();
    }
}

void mouseReleased() { // Launch the ball when the plunger is released!
    plunger.release();

    float forceMultiplier = -750;  // Adjust this value to change the strength of the launch

    if (ball.collidesWithPlunger(plunger)) {            // Only apply force when ball is touching plunger
        ball.applyForce(new Vec2(0.0, forceMultiplier));
    }
}
void loadScene(String filename) {
    circles.clear(); // clear existing obstacles

    String[] lines = loadStrings(filename);
    for (String line : lines) {
        String[] parts = split(line, ' ');

        if (parts[0].equals("circle")) {
            float x = float(parts[1]);
            float y = float(parts[2]);
            float r = float(parts[3]);

            Circle c = new Circle(new Vec2(x, y), r);
            circles.add(c);
        }
        // Add more obstacle types as needed
    }
}
