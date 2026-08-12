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

pred cap001696 { ((some x: CapBenchA | x->x in capBenchR) and (inv11 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap001696c { (some x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchR and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001696 { cap001696 iff cap001696c }
check CapBenchEquivalent_cap001696 for 4
