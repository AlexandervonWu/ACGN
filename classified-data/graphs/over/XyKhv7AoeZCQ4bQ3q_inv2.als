sig Node {
	adj : set Node
}
pred inv2 {
no n : Node, n2 : n.adj | n in n2.adj
not inv1
}

pred inv1{
all n : Node, n2 : n.adj | n in n2.adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



