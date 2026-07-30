sig Node {
	adj : set Node
}
pred inv3 {
all n : Node | #(n.adj) = (#n)-1
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



