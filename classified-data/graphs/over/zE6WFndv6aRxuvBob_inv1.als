sig Node {
	adj : set Node
}
pred inv1 {
all n:Node, n2:Node | n2 in n.adj => not n2 in n.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



