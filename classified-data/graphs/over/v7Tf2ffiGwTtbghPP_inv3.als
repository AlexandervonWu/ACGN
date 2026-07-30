sig Node {
	adj : set Node
}
pred inv3 {
inv2
all n : Node | no n.adj
}

pred inv2{
all n1, n2 : Node | n1->n2 in adj implies not n2->n1 in adj
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



