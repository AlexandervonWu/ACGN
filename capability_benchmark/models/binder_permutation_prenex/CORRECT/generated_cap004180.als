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

pred cap004180 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap004180c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap004180 { cap004180 iff cap004180c }
check CapBenchEquivalent_cap004180 for 4
