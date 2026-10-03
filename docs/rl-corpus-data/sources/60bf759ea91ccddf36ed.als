sig Node {
	adj : set Node
}
pred inv1 {
iden in adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




// Independent bounded RL evaluation profile.
run {} for 3
