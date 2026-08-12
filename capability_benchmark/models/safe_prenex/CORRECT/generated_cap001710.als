var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always all f:Protected | f not in Trash
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001710 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((no CapBenchA and no CapBenchA) and no CapBenchB))) }
pred cap001710c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((no CapBenchA and no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001710 { cap001710 iff cap001710c }
check CapBenchEquivalent_cap001710 for 4
