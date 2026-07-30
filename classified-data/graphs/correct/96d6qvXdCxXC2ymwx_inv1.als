sig Node {
	adj : set Node
}
pred inv1 {
all a,b : Node | b in a.adj implies a in b.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



