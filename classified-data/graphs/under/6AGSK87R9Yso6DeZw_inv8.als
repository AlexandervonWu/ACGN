sig Node {
	adj : set Node
}
pred inv8 {
all n, n2 : Node | some n1 : Node | n->n1 in adj and n1->n2 in adj => n->n2 in adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



