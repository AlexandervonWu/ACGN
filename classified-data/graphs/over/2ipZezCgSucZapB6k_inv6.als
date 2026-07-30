sig Node {
	adj : set Node
}
pred inv6 {
all n:Node, x:Node| (n in x.adj or n in x.~adj)&& (x in n.adj || x in n.~adj)
}

pred inv6c {
	all n:Node | Node = n.*(adj+~adj)
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



