sig Node {
	adj : set Node
}
pred inv1 {
all v1, v2 : Node | v1->v2 in adj implies v2->v1 in adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



