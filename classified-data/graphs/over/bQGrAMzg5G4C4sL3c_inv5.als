sig Node {
	adj : set Node
}
pred inv5 {
no n1: Node | n1 in n1.^adj
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



