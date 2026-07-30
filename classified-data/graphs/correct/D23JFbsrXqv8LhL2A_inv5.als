sig Node {
	adj : set Node
}
pred inv5 {
no iden & adj

all n : Node | n not in n.adj
}

fun inv1Enclosure : Node -> Node {
{n1 : Node, n2 : Node | n2 in n1.adj or n1 in n2.adj}
}

pred inv1{
all disj n1,n2 : Node | n2 in n1.adj => n2 in adj.n1
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



