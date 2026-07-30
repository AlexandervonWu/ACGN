sig Node {
	adj : set Node
}
pred inv2 {
all x,y:Node | x->y in adj implies y->x not in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



