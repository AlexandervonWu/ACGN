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

pred cap004495 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004495c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004495 { cap004495 iff cap004495c }
check CapBenchEquivalent_cap004495 for 4
