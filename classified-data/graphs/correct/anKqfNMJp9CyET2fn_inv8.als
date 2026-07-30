sig Node {
	adj : set Node
}
pred inv8 {
all a,b,c:Node | (a->b in adj and b->c in adj) implies a->c in adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



