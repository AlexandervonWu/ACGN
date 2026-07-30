sig Node {
	adj : set Node
}
pred inv2 {
all disj n1,n2: Node | n1 in n2.adj implies n2 not in n1.adj and n2 in n1.adj implies n1 not in n2.adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



