sig Node {
	adj : set Node
}
pred inv8 {
inv5
}

pred inv5{
no iden & adj

all n : Node | n not in n.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



