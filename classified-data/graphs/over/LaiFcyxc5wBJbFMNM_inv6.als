sig Node {
	adj : set Node
}
pred inv6 {
all n1,n2:Node | n1 in adj.n2 and n2 in adj.n1
}

pred inv6c {
	all n:Node | Node = n.*(adj+~adj)
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



