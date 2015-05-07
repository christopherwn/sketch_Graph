int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[500];

static final color nodeColor   = #03FF00;
static final color selectColor = #FF3030;
static final color fixedColor  = #FF8080;
static final color edgeColor   = #000000;

PFont font;


void setup() {
  size(800, 800);  
  loadData();
  font = createFont("SansSerif", 10);
  writeData();  
}


void writeData() {
  PrintWriter writer = createWriter("DONTOVERWRITETHISPRICK.txt");
  writer.println("digraph output {");
  for (int i = 0; i < edgeCount; i++) {
    String from = "\"" + edges[i].from.label + "\"";
    String to = "\"" + edges[i].to.label + "\"";
    writer.println(TAB + from + " -> " + to + ";");
  }
  writer.println("}");
  writer.flush();
  writer.close();
}


void loadData() {
  String[] lines = loadStrings("pokemon150.txt");
  

  for (int i = 0; i < lines.length; i++) {
    String[] line = lines[i].split("\t");
    addEdge(line[0], line[1]);
      }
}


void addEdge(String fromLabel, String toLabel) {
  // Filter out unnecessary words
  if (ignoreWord(fromLabel) || ignoreWord(toLabel)) return;
  
  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  from.increment();
  to.increment();
  
  for (int i = 0; i < edgeCount; i++) {
    if (edges[i].from == from && edges[i].to == to) {
      edges[i].increment();
      return;
    }
  } 
  
  Edge e = new Edge(from, to);
  e.increment();
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e;
}


String[] ignore = { "a", "of", "the", "i", "it", "you", "and", "to" };

boolean ignoreWord(String what) {
  for (int i = 0; i < ignore.length; i++) {
    if (what.equals(ignore[i])) {
      return true;
    }
  }
  return false;
}


Node findNode(String label) {
  label = label.toLowerCase();
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n;
}


Node addNode(String label) {
  Node n = new Node(label);  
  if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
  }
  nodeTable.put(label, n);
  nodes[nodeCount++] = n;  
  return n;
}


void draw() {
  if (record) {
    beginRecord(PDF, "output.pdf");
  }

  background(255);
  textFont(font);  
  smooth();  
  textSize(25);
  fill(#ff0000);
  for(int i=0;i<nodeCount;i++) {
    if(dist(mouseX,mouseY,nodes[i].getX(),nodes[i].getY())<7){
      
       text(nodes[i].getLabel(),mouseX,mouseY); 
    }
  }
  for (int i = 0 ; i < edgeCount ; i++) {
    edges[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].update();
  }
  for (int i = 0 ; i < edgeCount ; i++) {
    edges[i].draw();
  }
  for (int i = 0 ; i < nodeCount ; i++) {
    nodes[i].draw();
  }
  
  if (record) {
    endRecord();
    record = false;
  }
}


boolean record;

void keyPressed() {
  if (key == 'r') {
    record = true;
  }
}


Node selection; 


void mousePressed() {
  // Ignore anything greater than this distance
  float closest = 20;
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < closest) {
      selection = n;
      closest = d;
    }
  }
  if (selection != null) {
    if (mouseButton == LEFT) {
      selection.fixed = true;
    } else if (mouseButton == RIGHT) {
      selection.fixed = false;
    }
  }
}


void mouseDragged() {
  if (selection != null) {
    selection.x = mouseX;
    selection.y = mouseY;
  }
}


void mouseReleased() {
  selection = null;
}
