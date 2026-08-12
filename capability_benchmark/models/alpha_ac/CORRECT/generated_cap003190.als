var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f : File | f not in Protected implies after f in Protected
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

pred cap003190 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((no CapBenchB or some capBenchS) and some capBenchS)) }
pred cap003190c { all renamed: CapBenchA | (((no CapBenchB or some capBenchS) and some capBenchS) and renamed->renamed in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003190 { cap003190 iff cap003190c }
check CapBenchEquivalent_cap003190 for 4
