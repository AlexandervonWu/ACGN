sig Node {
	adj : set Node
}
pred inv4 {
all n: Node | some (n.adj + adj.n)
}

pred inv4c {
	adj = Node -> Node
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



