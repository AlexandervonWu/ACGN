sig Node {
	adj : set Node
}
pred inv2 {
all n1:Node | some n2:Node | n2 in n1.adj implies n1 not in n2.adj
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



