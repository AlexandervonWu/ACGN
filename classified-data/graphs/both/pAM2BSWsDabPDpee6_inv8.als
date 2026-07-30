sig Node {
	adj : set Node
}
pred inv8 {
all disj n1,n2,n3: Node | (n1 in n3.adj or n3 in n1.adj) and (n3 in n2.adj or n2 in n3.adj) implies (n1 in n2.adj or n2 in n1.adj)
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



