sig Node {
	adj : set Node
}
pred inv7 {
all x, y: Node | x in y.^(adj) or x in adj.y or x = y
}

pred inv7c {
	all n:Node | Node = n.*adj
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



