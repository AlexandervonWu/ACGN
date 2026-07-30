sig Node {
	adj : set Node
}
pred inv5 {
all n1,n2:Node | some n1.adj:>n2 implies n1 != n2
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



