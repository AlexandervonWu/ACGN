sig Node {
	adj : set Node
}
pred inv7 {
all n1, n2: Node | n2 in n1.^(adj)
}

pred inv7c {
	all n:Node | Node = n.*adj
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



