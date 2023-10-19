public class TableOutline {
    public Line[] tablePos;

    public TableOutline() {
        tablePos = new Line[13];

        tablePos[0] = new Line(new Vec2(32, 155), new Vec2(32, 449));      // Left
        tablePos[1] = new Line(new Vec2(32, 449), new Vec2(63, 495));
        tablePos[2] = new Line(new Vec2(63, 495), new Vec2(63, 645));
        tablePos[3] = new Line(new Vec2(96, 465), new Vec2(96, 650));
        tablePos[4] = new Line(new Vec2(63, 650), new Vec2(96, 650));
        tablePos[5] = new Line(new Vec2(96, 617), new Vec2(159,689));

        tablePos[6] = new Line(new Vec2(353, 155), new Vec2(353, 389));    // Right
        tablePos[7] = new Line(new Vec2(353, 389), new Vec2(288, 495));
        tablePos[8] = new Line(new Vec2(288, 495), new Vec2(288, 617));
        tablePos[9] = new Line(new Vec2(288, 617), new Vec2(225, 689));


        tablePos[10] = new Line(new Vec2(32, 155), new Vec2(113, 89));    // Top
        tablePos[11] = new Line(new Vec2(353, 155), new Vec2(272, 89));
        tablePos[12] = new Line(new Vec2(113, 89), new Vec2(272, 89));

    }

    public void makeTable() {
        for (int i=0; i < tablePos.length; i++) {
            Vec2 p1 = tablePos[i].p1;
            Vec2 p2 = tablePos[i].p2;

            drawLine(p1.x, p1.y, p2.x, p2.y);
        }
    }
}

// Add any other methods that are specific to the table's outline.
public class Line {
    public Vec2 p1, p2;

    public Line(Vec2 p1, Vec2 p2) {
        this.p1 = p1;
        this.p2 = p2;
    }

    public float length() {
        float distX = p2.x - p1.x;
        float distY = p2.y - p1.y;

        return sqrt((distX * distX) + (distY * distY));
    }
}

void drawLine(float startX, float startY, float endX, float endY) {
    pushMatrix();
    stroke(0, 11, 255);
    strokeWeight(5);
    line(startX, startY, endX, endY);
    popMatrix();
}
