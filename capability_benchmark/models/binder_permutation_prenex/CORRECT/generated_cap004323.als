var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
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

pred cap004323 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap004323c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap004323 { cap004323 iff cap004323c }
check CapBenchEquivalent_cap004323 for 4
