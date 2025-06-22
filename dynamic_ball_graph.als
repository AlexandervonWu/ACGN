sig Node {
  edges: set Node
}

fact ConnectedGraph {
  all n: Node | n.*edges = Node
}

fact NoSelfEdges {
  no iden & edges
} 

one sig Ball {
  -- note the var
  var loc: Node 
}
pred move[b: Ball, n: Node] {
  n in b.loc.edges
  b.loc' = n
}

pred moved[b: Ball] {
  some n: Node | move[b, n]
}

pred unchanged[b: Ball] {
  b.loc = b.loc'
}

pred TestIdea{
  some b: Ball |
    always moved[b]
}

pred TestIdea2{
  all b: Ball |
    always moved[b]
}

run TestIdea
