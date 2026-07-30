sig Node {
	adj : set Node
}
pred inv1 {
all n : Node | all ad : n.adj | n in ad.adj and ad.adj in n
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



