var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f: (File - Protected) | after f in Protected
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004162 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((no CapBenchA and some capBenchR) and no CapBenchA))) }
pred cap004162c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((no CapBenchA and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap004162 { cap004162 iff cap004162c }
check CapBenchEquivalent_cap004162 for 4
