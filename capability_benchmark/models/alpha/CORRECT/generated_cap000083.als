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

pred cap000083 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap000083c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv11 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000083 { cap000083 iff cap000083c }
check CapBenchEquivalent_cap000083 for 4
