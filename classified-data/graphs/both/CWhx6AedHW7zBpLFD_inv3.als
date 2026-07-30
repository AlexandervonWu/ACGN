sig Node {
	adj : set Node
}
pred inv3 {
all x, y, z : Node | x->y in adj and z->y in adj implies y = z and z = x
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



