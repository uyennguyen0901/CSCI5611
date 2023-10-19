class Particle {
    Vec2 position;
    Vec2 velocity;
    float lifespan = 255.0;

    Particle(Vec2 pos) {
        position = new Vec2(pos.x, pos.y);
        float angle = random(TWO_PI);
        float magnitude = random(2, 5);
        velocity = new Vec2(cos(angle) * magnitude, sin(angle) * magnitude);
    }

    void update() {
        position.x += velocity.x;
        position.y += velocity.y;
        lifespan -= 2.0;
    }

    void display() {
        stroke(255, lifespan);
        strokeWeight(2);
        fill(127, lifespan);
        ellipse(position.x, position.y, 12, 12);
    }

    boolean isDead() {
        return lifespan < 0;
    }
}
class ParticleSystem {
    ArrayList<Particle> particles = new ArrayList<Particle>();
    Vec2 origin;

    ParticleSystem(Vec2 position) {
        origin = position;
    }

    void addParticle() {
        particles.add(new Particle(origin));
    }

    void run() {
        for (int i = particles.size() - 1; i >= 0; i--) {
            Particle p = particles.get(i);
            p.update();
            p.display();
            if (p.isDead()) {
                particles.remove(i);
            }
        }
    }
}
