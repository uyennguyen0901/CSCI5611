//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
    public float x, y;

    public Vec2(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public String toString() {
        return "(" + x+ "," + y +")";
    }

    public float length() {
        return sqrt(x*x+y*y);
    }

    public Vec2 plus(Vec2 rhs) {
        return new Vec2(x+rhs.x, y+rhs.y);
    }

    public void add(Vec2 rhs) {
        x += rhs.x;
        y += rhs.y;
    }

    public Vec2 minus(Vec2 rhs) {
        return new Vec2(x-rhs.x, y-rhs.y);
    }

    public void subtract(Vec2 rhs) {
        x -= rhs.x;
        y -= rhs.y;
    }

    public Vec2 times(float rhs) {
        return new Vec2(x*rhs, y*rhs);
    }

    public void mul(float rhs) {
        x *= rhs;
        y *= rhs;
    }

    public void clampToLength(float maxL) {
        float magnitude = sqrt(x*x + y*y);
        if (magnitude > maxL) {
            x *= maxL/magnitude;
            y *= maxL/magnitude;
        }
    }

    public void setToLength(float newL) {
        float magnitude = sqrt(x*x + y*y);
        x *= newL/magnitude;
        y *= newL/magnitude;
    }

    public void normalize() {
        float magnitude = sqrt(x*x + y*y);
        x /= magnitude;
        y /= magnitude;
    }

    public Vec2 normalized() {
        float magnitude = sqrt(x*x + y*y);
        return new Vec2(x/magnitude, y/magnitude);
    }

    public float distanceTo(Vec2 rhs) {
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        return sqrt(dx*dx + dy*dy);
    }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t) {
    return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
    return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b) {
    return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b) {
    return b.times(a.x*b.x + a.y*b.y);
}

Vec2 closestPointOnSegment(Vec2 a, Vec2 b, Vec2 p) {
    float apx = p.x - a.x;
    float apy = p.y - a.y;
    float abx = b.x - a.x;
    float aby = b.y - a.y;

    float magAB2 = abx*abx + aby*aby;
    float apDotAB = apx*abx + apy*aby;

    float t = apDotAB / magAB2;

    if (t < 0.0f) {
        return new Vec2(a.x, a.y);
    } else if (t > 1.0f) {
        return new Vec2(b.x, b.y);
    }
    return new Vec2(a.x + abx*t, a.y + aby*t);
}

float distSquared(Vec2 a, Vec2 b) {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    return dx * dx + dy * dy;
}

float distanceSquaredPointSegment(Vec2 a, Vec2 b, Vec2 p) {
    Vec2 ab = b.minus(a);
    Vec2 ap = p.minus(a);
    Vec2 bp = p.minus(b);

    float e = dot(ap, ab);
    if (e <= 0.0f) return dot(ap, ap);

    float f = dot(ab, ab);
    if (e >= f) return dot(bp, bp);

    return dot(ap, ap) - e * e / f;
}

boolean isZero(Vec2 v) {
    float threshold = 0.01;
    return abs(v.x) < threshold && abs(v.y) < threshold;
}
