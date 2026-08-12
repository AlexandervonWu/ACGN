var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004158 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
pred cap004158c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap004158 { cap004158 iff cap004158c }
check CapBenchEquivalent_cap004158 for 4
