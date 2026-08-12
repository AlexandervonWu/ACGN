var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always (all f : File | f not in Protected implies after f in Protected)
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

pred cap000329 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap000329c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv11 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000329 { cap000329 iff cap000329c }
check CapBenchEquivalent_cap000329 for 4
