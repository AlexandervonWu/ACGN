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

pred cap001602 { ((some x: CapBenchA | x->x in capBenchR) and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
pred cap001602c { (some x: CapBenchA | (x->x in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001602 { cap001602 iff cap001602c }
check CapBenchEquivalent_cap001602 for 4
