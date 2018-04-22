class MeshFV {
  int scale = 50;
  
  PShape shpFaceEdges, shpWireframe, shpFaces, shpPoints;
  ArrayList<PVector> vertices;
  ArrayList<PFace> faces;
  
  MeshFV(JSONObject data) {
    this.vertices = new ArrayList<PVector>();
    this.faces = new ArrayList<PFace>();
    
    JSONArray vertices = data.getJSONArray("vertices");
    JSONArray faces = data.getJSONArray("faces");
    
    for (int i = 0; i < vertices.size(); i++) {
      JSONArray vertice = vertices.getJSONArray(i);
      float x = vertice.getFloat(0) * this.scale;
      float y = vertice.getFloat(1) * this.scale;
      float z = vertice.getFloat(2) * this.scale;
      this.vertices.add(new PVector(x, y, z));
    }
    
    for (int i = 0; i < faces.size(); i++) {
      JSONArray face = faces.getJSONArray(i);
      PVector v0 = this.vertices.get(face.getInt(0));
      PVector v1 = this.vertices.get(face.getInt(1));
      PVector v2 = this.vertices.get(face.getInt(2));
      this.faces.add(new PFace(v0, v1, v2));
    }
    
    pushStyle();
    
    int kind = TRIANGLES;
    strokeWeight(2);
    stroke(color(0, 255, 0));
    fill(color(255, 0, 0, 125));
    
    // Face edges
    this.shpFaceEdges = createShape(); 
    this.shpFaceEdges.beginShape(kind);
    for (PFace face : this.faces) {
      this.shpFaceEdges.vertex(face.v0.x, face.v0.y, face.v0.z);
      this.shpFaceEdges.vertex(face.v1.x, face.v1.y, face.v1.z);
      this.shpFaceEdges.vertex(face.v2.x, face.v2.y, face.v2.z);
    }
    this.shpFaceEdges.endShape();
    
    // Wireframe
    noFill();
    this.shpWireframe = createShape(); 
    this.shpWireframe.beginShape(kind);
    for (PFace face : this.faces) {
      this.shpWireframe.vertex(face.v0.x, face.v0.y, face.v0.z);
      this.shpWireframe.vertex(face.v1.x, face.v1.y, face.v1.z);
      this.shpWireframe.vertex(face.v2.x, face.v2.y, face.v2.z);
    }
    this.shpWireframe.endShape();
    
    // Faces
    fill(color(255, 0, 0, 125));
    noStroke();
    this.shpFaces = createShape(); 
    this.shpFaces.beginShape(kind);
    for (PFace face : this.faces) {
      this.shpFaces.vertex(face.v0.x, face.v0.y, face.v0.z);
      this.shpFaces.vertex(face.v1.x, face.v1.y, face.v1.z);
      this.shpFaces.vertex(face.v2.x, face.v2.y, face.v2.z);
    }
    this.shpFaces.endShape();
    
    // Points
    stroke(color(0, 255, 0));
    strokeWeight(3);
    kind = POINTS;
    this.shpPoints = createShape(); 
    this.shpPoints.beginShape(kind);
    for (PFace face : this.faces) {
      this.shpPoints.vertex(face.v0.x, face.v0.y, face.v0.z);
      this.shpPoints.vertex(face.v1.x, face.v1.y, face.v1.z);
      this.shpPoints.vertex(face.v2.x, face.v2.y, face.v2.z);
    }
    this.shpPoints.endShape();
    
    popStyle();
  }
  
  void drawRetained() {
    switch(mode) {
      case 0:
        shape(this.shpFaceEdges);
        break;
      case 1:
        shape(this.shpWireframe);
        break;
      case 2:
        shape(this.shpFaces);
        break;
      case 3:
        shape(this.shpPoints);
        break;
    }
  }
  
  void drawImmediate() {
    pushStyle();
    
    int kind = TRIANGLES;
    strokeWeight(2);
    stroke(color(0, 255, 0));
    fill(color(255, 0, 0, 125));

    // visual modes
    switch(mode) {
    case 1:
      noFill();
      break;
    case 2:
      noStroke();
      break;
    case 3:
      strokeWeight(3);
      kind = POINTS;
      break;
    }
    
    beginShape(kind);
    for (PFace face : this.faces) {
      vertex(face.v0.x, face.v0.y, face.v0.z);
      vertex(face.v1.x, face.v1.y, face.v1.z);
      vertex(face.v2.x, face.v2.y, face.v2.z);
    }
    endShape();
  }
}

class PFace {
  PVector v0;
  PVector v1;
  PVector v2;
  
  PFace(PVector v0, PVector v1, PVector v2) {
    this.v0 = v0;
    this.v1 = v1;
    this.v2 = v2;
  }
}
