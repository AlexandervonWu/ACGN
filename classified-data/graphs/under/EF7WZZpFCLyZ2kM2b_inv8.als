sig Node {
	adj : set Node
}
pred inv8 {
all n1, n2, n3:Node | n1->n2 in adj and n2->n3 in adj => n1->n2 in adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



