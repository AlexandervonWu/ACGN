sig Node {
	adj : set Node
}
pred inv1 {
all e1, e2 : Node | e1 -> e2 in adj implies e2 -> e1 in adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



