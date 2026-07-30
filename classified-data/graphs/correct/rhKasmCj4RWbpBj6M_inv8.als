sig Node {
	adj : set Node
}
pred inv8 {
all x, y, z: Node | x in y.adj and y in z.adj implies x in z.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



