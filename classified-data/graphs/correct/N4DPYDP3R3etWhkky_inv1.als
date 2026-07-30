sig Node {
	adj : set Node
}
pred inv1 {
all n1,n2:Node | some n1.adj:>n2 implies some n2.adj:>n1
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



