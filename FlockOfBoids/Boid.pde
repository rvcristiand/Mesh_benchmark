class Boid {
  Node node;
  int grabsMouseColor;
  int avatarColor;
  // fields
  Vector position, velocity, acceleration, alignment, cohesion, separation; // position, velocity, and acceleration in
  // a vector datatype
  float neighborhoodRadius; // radius in which it looks for fellow boids
  float maxSpeed = 4; // maximum magnitude for the velocity vector
  float maxSteerForce = .1f; // maximum magnitude of the steering vector
  float sc = 3; // scale factor for the render of the boid
  float flap = 0;
  float t = 0;

  MeshVV meshVV;
  MeshFV meshFV;

  Boid(Vector inPos, MeshVV meshVV, MeshFV meshFV) {
    grabsMouseColor = color(0, 0, 255);
    avatarColor = color(255, 255, 0);
    position = new Vector();
    position.set(inPos);
    node = new Node(scene) {
      // Note that within visit() geometry is defined at the
      // node local coordinate system.
      @Override
        public void visit() {
        if (animate)
          run(flock);
        render();
      }

      // Behaviour: tapping over a boid will select the node as
      // the eye reference and perform an eye interpolation to it.
      @Override
        public void interact(TapEvent event) {
        if (avatar != this && scene.eye().reference() != this) {
          avatar = this;
          scene.eye().setReference(this);
          scene.interpolateTo(this);
        }
      }
    };
    node.setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(random(-1, 1), random(-1, 1), random(1, -1));
    acceleration = new Vector(random(0, 5), random(0, 5), random(0, 5));
    neighborhoodRadius = 100;
    this.meshVV = meshVV;
    this.meshFV = meshFV;
  }

  public void run(ArrayList<Boid> boids) {
    t += .1;
    flap = 10 * sin(t);
    // acceleration.add(steer(new Vector(mouseX,mouseY,300),true));
    // acceleration.add(new Vector(0,.05,0));
    if (avoidWalls) {
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), flockHeight, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), 0, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(flockWidth, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(0, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), 0)), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), flockDepth)), 5));
    }
    flock(boids);
    move();
    checkBounds();
  }

  Vector avoid(Vector target) {
    Vector steer = new Vector(); // creates vector for steering
    steer.set(Vector.subtract(position, target)); // steering vector points away from
    steer.multiply(1 / sq(Vector.distance(position, target)));
    return steer;
  }

  //-----------behaviors---------------

  void flock(ArrayList<Boid> boids) {
    //alignment
    alignment = new Vector(0, 0, 0);
    int alignmentCount = 0;
    //cohesion
    Vector posSum = new Vector();
    int cohesionCount = 0;
    //separation
    separation = new Vector(0, 0, 0);
    Vector repulse;
    for (int i = 0; i < boids.size(); i++) {
      Boid boid = boids.get(i);
      //alignment
      float distance = Vector.distance(position, boid.position);
      if (distance > 0 && distance <= neighborhoodRadius) {
        alignment.add(boid.velocity);
        alignmentCount++;
      }
      //cohesion
      float dist = dist(position.x(), position.y(), boid.position.x(), boid.position.y());
      if (dist > 0 && dist <= neighborhoodRadius) {
        posSum.add(boid.position);
        cohesionCount++;
      }
      //separation
      if (distance > 0 && distance <= neighborhoodRadius) {
        repulse = Vector.subtract(position, boid.position);
        repulse.normalize();
        repulse.divide(distance);
        separation.add(repulse);
      }
    }
    //alignment
    if (alignmentCount > 0) {
      alignment.divide((float) alignmentCount);
      alignment.limit(maxSteerForce);
    }
    //cohesion
    if (cohesionCount > 0)
      posSum.divide((float) cohesionCount);
    cohesion = Vector.subtract(posSum, position);
    cohesion.limit(maxSteerForce);

    acceleration.add(Vector.multiply(alignment, 1));
    acceleration.add(Vector.multiply(cohesion, 3));
    acceleration.add(Vector.multiply(separation, 1));
  }

  void move() {
    velocity.add(acceleration); // add acceleration to velocity
    velocity.limit(maxSpeed); // make sure the velocity vector magnitude does not
    // exceed maxSpeed
    position.add(velocity); // add velocity to position
    node.setPosition(position);
    node.setRotation(Quaternion.multiply(new Quaternion(new Vector(0, 1, 0), atan2(-velocity.x(), velocity.z())), 
      new Quaternion(new Vector(0, 0, 1), asin(velocity.y() / velocity.magnitude()))));
    acceleration.multiply(0); // reset acceleration
  }

  void checkBounds() {
    if (position.x() > flockWidth)
      position.setX(0);
    if (position.x() < 0)
      position.setX(flockWidth);
    if (position.y() > flockHeight)
      position.setY(0);
    if (position.y() < 0)
      position.setY(flockHeight);
    if (position.z() > flockDepth)
      position.setZ(0);
    if (position.z() < 0)
      position.setZ(flockDepth);
  }

  void render() {
    // uncomment to draw boid axes
    if (drawAxes) {
      scene.drawAxes(100);
    } else {
      scene.drawAxes(0);
    }

    // highlight boids under the mouse
    if (node.track(mouseX, mouseY)) {
      noStroke();
      fill(grabsMouseColor);
    }

    // highlight avatar
    if (node == avatar) {
      noStroke();
      fill(avatarColor);
    }

    // representation mode
    if (representationMode == 0) {
      //draw boid
      if (drawMode == 0) {
        this.meshVV.drawRetained();
      } else {
        this.meshVV.drawImmediate();
      }
    } else {
      if (drawMode == 0) {
        this.meshFV.drawRetained();
      } else {
        this.meshFV.drawImmediate();
      }
    }
  }
}
