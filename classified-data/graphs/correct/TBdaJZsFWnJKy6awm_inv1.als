sig Node {
	adj : set Node
}
pred inv1 {
all x,y : Node | x->y in adj implies y->x in adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



