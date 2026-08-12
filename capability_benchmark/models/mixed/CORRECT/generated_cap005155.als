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

pred cap005155 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((no CapBenchB or no CapBenchB) and no CapBenchA)) and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
pred cap005155c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or some capBenchS)) or (not (inv9 and ((no CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005155 { cap005155 iff cap005155c }
check CapBenchEquivalent_cap005155 for 4
