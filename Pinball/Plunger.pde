import processing.sound.*;

class Plunger {
    final float acceleration = 2.0;
    final float maxPullBack = 20;
    final float initialHeight = 36;
    Vec2 position;
    PImage img;
    float plungerHeight;
    float plungerWidth;
    float speed;
    boolean isPulled;
    ParticleSystem fireworks;
    PApplet p;
    SoundFile plungerSound;
    public Plunger(Vec2 pos, PImage img, String soundPath, PApplet p) {
        position = pos;
        plungerHeight = 144;
        plungerWidth = 28;
        speed = 0.0;
        isPulled = false;
        plungerSound = new SoundFile(p, soundPath);
        this.img = img;
    }

    void update(float dt) {
        if (isPulled) {
            plungerSound.play();
            speed += acceleration * dt;
            if (position.y + speed * dt >= maxPullBack) {
                speed = 0;
            } else {
                position.y += speed * dt;
            }
        } else {
            speed += -acceleration * dt;
        }

        float initialHeight = plungerHeight;
        float nextHeight = plungerHeight + speed * dt;
        if (nextHeight <= plungerHeight) {
            plungerHeight = initialHeight;
            speed = 0;
        } else {
            plungerHeight += speed * dt;
        }
    }

    void display() {
        fill(255, 0, 0);
        image(img, position.x, position.y, plungerWidth, plungerHeight);
    }

    void pull() {
        isPulled = true;
        fireworks = new ParticleSystem(new Vec2(300, 400));
        for (int i = 0; i < 100; i++) {
            fireworks.addParticle();
        }
    }

    void release() {
        isPulled = false;
    }
}
