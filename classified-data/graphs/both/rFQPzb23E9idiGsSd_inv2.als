sig Node {
	adj : set Node
}
pred inv2 {
all n, n1 : Node | n->n1 in adj and n1->n in adj <=> n1 = n
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



