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

pred cap004020 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
pred cap004020c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap004020 { cap004020 iff cap004020c }
check CapBenchEquivalent_cap004020 for 4
