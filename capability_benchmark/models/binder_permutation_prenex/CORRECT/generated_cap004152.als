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

pred cap004152 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
pred cap004152c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004152 { cap004152 iff cap004152c }
check CapBenchEquivalent_cap004152 for 4
