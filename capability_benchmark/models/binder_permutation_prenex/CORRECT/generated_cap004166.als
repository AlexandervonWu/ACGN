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

pred cap004166 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
pred cap004166c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap004166 { cap004166 iff cap004166c }
check CapBenchEquivalent_cap004166 for 4
