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

pred cap005034 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((no CapBenchA and some capBenchR) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap005034c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) or (not (inv9 and ((no CapBenchA and some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005034 { cap005034 iff cap005034c }
check CapBenchEquivalent_cap005034 for 4
