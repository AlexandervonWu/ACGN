sig Node {
	adj : set Node
}
pred inv2 {
all e1, e2 : Node | e1 -> e2 in adj implies e2 -> e1 not in adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



