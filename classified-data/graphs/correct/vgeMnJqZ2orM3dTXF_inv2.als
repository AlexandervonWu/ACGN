sig Node {
	adj : set Node
}
pred inv2 {
all v1, v2 : Node | v1->v2 in adj implies not v2->v1 in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



