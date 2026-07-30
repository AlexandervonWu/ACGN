sig Node {
	adj : set Node
}
pred inv8 {
all n1, n2, n3 : Node | (some(n1->n2) and some(n2->n3)) implies some(n1->n3)
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



