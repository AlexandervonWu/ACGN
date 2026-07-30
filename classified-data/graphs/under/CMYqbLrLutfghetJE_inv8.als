sig Node {
	adj : set Node
}
pred inv8 {
all n1 : Node | some n2 : Node | n2 in n1.adj implies n1 in n2.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



