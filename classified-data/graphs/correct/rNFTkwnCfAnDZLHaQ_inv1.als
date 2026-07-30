sig Node {
	adj : set Node
}
pred inv1 {
all n1, n2: Node | n2 in n1.adj iff n1 in n2.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



