sig Node {
	adj : set Node
}
pred inv2 {
all x, y, z: Node | (y in x.adj and z in y.adj) implies z != x
}

pred inv2c {
	no adj & ~adj
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



