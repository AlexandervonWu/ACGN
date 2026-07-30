sig Node {
	adj : set Node
}
pred inv3 {
all v1, v2 : Node | v1->v2 in adj and v2->v1 in adj implies v1 = v2 & v1
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



