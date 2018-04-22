class MeshVV {
  int scale = 50;

  PShape sFaceEdges, sWireframe, sFaces, sPoints;
  ArrayList<PVector> coordinates;
  ArrayList<IntList> vertices;
  
  MeshVV(JSONObject data) {
    this.coordinates = new ArrayList<PVector>();
    this.vertices = new ArrayList<IntList>();
    
    JSONArray coordinates = data.getJSONArray("coordinates");
    JSONArray vertices = data.getJSONArray("vertices");
    
    for (int i = 0; i < coordinates.size(); i++) {
      JSONArray coordinate = coordinates.getJSONArray(i);
      float x = this.scale * coordinate.getFloat(0);
      float y = this.scale * coordinate.getFloat(1);
      float z = this.scale * coordinate.getFloat(2);
      this.coordinates.add(new PVector(x, y, z));
    }
    
    for (int i = 0; i < vertices.size(); i++) {
      JSONArray vertex = vertices.getJSONArray(i);
      IntList auxVertex = new IntList();
      
      for (int j = 0; j < vertex.size(); j++) {
        auxVertex.append(vertex.getInt(j));
      }
      
      this.vertices.add(auxVertex);
    }
    
    pushStyle();
    
    int kind = TRIANGLES;
    strokeWeight(2);
    stroke(color(0, 255, 0));
    fill(color(0, 0, 255, 125));
    
    // Face edges
    this.sFaceEdges = createShape();
    this.sFaceEdges.beginShape(kind);
    this.draw(sFaceEdges);
    this.sFaceEdges.endShape();
    
    // Wireframe
    noFill();
    this.sWireframe = createShape();
    this.sWireframe.beginShape(kind);
    this.draw(sWireframe);
    this.sWireframe.endShape();
    
    // Faces
    noStroke();
    fill(color(0, 0, 255, 125));
    this.sFaces = createShape();
    this.sFaces.beginShape(kind);
    this.draw(sFaces);
    this.sFaces.endShape();
    
    // Point
    stroke(color(0, 255, 0));
    strokeWeight(3);
    kind = POINTS;
    this.sPoints = createShape();
    this.sPoints.beginShape(kind);
    this.draw(sPoints);
    this.sPoints.endShape();
    
    popStyle();
  }
  
  void drawRetained() {
    switch(mode) {
      case 0:
        shape(this.sFaceEdges);
        break;
      case 1:
        shape(this.sWireframe);
        break;
      case 2:
        shape(this.sFaces);
        break;
      case 3:
        shape(this.sPoints);
        break;
    }
  }
  
  void drawImmediate() {
    pushStyle();
    
    int kind = TRIANGLES;
    strokeWeight(2);
    stroke(color(0, 255, 0));
    fill(color(0, 0, 255, 125));

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
    this.draw();
    endShape();
  }
  
  void draw() {
    int i = 0;
    for (IntList vertex: this.vertices) {
      for (int j = 0; j < vertex.size() - 1; j++) {
        vertex(this.coordinates.get(i).x, this.coordinates.get(i).y, this.coordinates.get(i).z);
        vertex(this.coordinates.get(vertex.get(j)).x, this.coordinates.get(vertex.get(j)).y, this.coordinates.get(vertex.get(j)).z);
        vertex(this.coordinates.get(vertex.get(j + 1)).x, 
               this.coordinates.get(vertex.get(j + 1)).y, 
               this.coordinates.get(vertex.get(j + 1)).z);
      }
      i+=1;
    }
  }
  
  void draw(PShape s){
    int i = 0;
    for (IntList vertex: this.vertices) {
      for (int j = 0; j < vertex.size() - 1; j++) {
        s.vertex(this.coordinates.get(i).x, this.coordinates.get(i).y, this.coordinates.get(i).z);
        s.vertex(this.coordinates.get(vertex.get(j)).x, this.coordinates.get(vertex.get(j)).y, this.coordinates.get(vertex.get(j)).z);
        s.vertex(this.coordinates.get(vertex.get(j + 1)).x, 
                 this.coordinates.get(vertex.get(j + 1)).y, 
                 this.coordinates.get(vertex.get(j + 1)).z);
      }
      i+=1;
    }
  }
}
