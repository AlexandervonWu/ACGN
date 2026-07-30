sig Node {
	adj : set Node
}
pred inv3 {
all n1:Node| some n2:Node | n1->n2 in adj implies n2->n1 not in adj
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



