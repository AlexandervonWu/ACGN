sig Node {
	adj : set Node
}
pred inv6 {
all e1 : Node | Node in e1.*adj + e1.*~adj
}

pred inv6c {
	all n:Node | Node = n.*(adj+~adj)
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



