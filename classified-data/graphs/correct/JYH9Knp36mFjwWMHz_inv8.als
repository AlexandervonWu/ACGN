sig Node {
	adj : set Node
}
pred inv8 {
all x, y, z : Node | x->y in adj and y->z in adj implies x->z in adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



