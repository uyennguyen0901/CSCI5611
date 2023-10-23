public class Vec3 {
    public float x, y, z;

    public Vec3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
     public void set(Vec3 v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
    }
    public String toString() {
        return "(" + x + "," + y + "," + z + ")";
    }

    public float length() {
        return sqrt(x * x + y * y + z * z);
    }

    public float lengthSqr() {
        return x * x + y * y + z * z;
    }

    public Vec3 plus(Vec3 rhs) {
        return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
    }

    public void add(Vec3 rhs) {
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
    }

    public Vec3 minus(Vec3 rhs) {
        return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
    }

    public void subtract(Vec3 rhs) {
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
    }

    public Vec3 times(float rhs) {
        return new Vec3(x * rhs, y * rhs, z * rhs);
    }

    public void mul(float rhs) {
        x *= rhs;
        y *= rhs;
        z *= rhs;
    }

    public void normalize() {
        float magnitude = sqrt(x * x + y * y + z * z);
        x /= magnitude;
        y /= magnitude;
        z /= magnitude;
    }

    
    public Vec3 normalized() {
        float magnitude = sqrt(x * x + y * y + z * z);
        return new Vec3(x / magnitude, y / magnitude, z / magnitude);
    }
    
     public float dot(Vec3 rhs) {
        return x * rhs.x + y * rhs.y + z * rhs.z;
    }
    
    public Vec3 copy() {
        return new Vec3(this.x, this.y, this.z);
    }
    
    public float distanceTo(Vec3 rhs) {
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        float dz = rhs.z - z;
        return sqrt(dx * dx + dy * dy + dz * dz);
    }
    public float magnitude() {
        return sqrt(x*x + y*y + z*z);
    }
    public Vec3 divide(float scalar) {
        return new Vec3(this.x / scalar, this.y / scalar, this.z / scalar);
    }
    
    
    public float distanceToLine(Vec3 A, Vec3 B) {
        Vec3 AP = this.minus(A);       // Vector from A to P
        Vec3 AB = B.minus(A);          // Vector from A to B
        
        float ab2 = AB.dot(AB);        // Length of AB squared
        float ap_ab = AP.dot(AB);      // The dot product of AP and AB
        float t = ap_ab / ab2;         // The normalized "distance" from A to the closest point
        
        if (t < 0.0f) {
            // P is closer to A
            return this.distanceTo(A);
        } else if (t > 1.0f) {
            // P is closer to B
            return this.distanceTo(B);
        }
        Vec3 C = A.plus(AB.times(t));  // Point on AB closest to P
        return this.distanceTo(C);     // Distance from P to C
    }
    

}
 Vec3 cross(Vec3 a, Vec3 b) {
    return new Vec3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    );
}
