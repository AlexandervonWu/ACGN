sig Node {
	adj : set Node
}
pred inv5 {
all x, y : Node | x->y in adj implies not (y->x in adj)
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



