sig Node {
	adj : set Node
}
pred inv5 {
all n : Node | n.adj not in n
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



