sig Node {
	adj : set Node
}
pred inv2 {
all n1,n2:Node | some n1.adj:>n2 implies no n2.adj:>n1
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



