sig Node {
	adj : set Node
}
pred inv3 {
all x, y : Node | ^(x->y) in adj implies ^(y->x) not in adj
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



