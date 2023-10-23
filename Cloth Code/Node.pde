class Node {
    Vec3 pos;
    Vec3 vel;
    boolean torn;
    Node(Vec3 pos, Vec3 vel) {
        this.pos = pos;
        this.vel = vel;
        torn = false;
    }
}
