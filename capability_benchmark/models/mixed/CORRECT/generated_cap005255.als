var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19 {
always all f : Protected | f in Protected until f in Trash
}

pred inv19c {
	always all f : Protected | f in Protected until f in Trash
}

check correct { inv19 <=> inv19c}
pred under { inv19 and !inv19c}
pred over { !inv19 and inv19c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005255 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv19 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005255c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv19 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005255 { cap005255 iff cap005255c }
check CapBenchEquivalent_cap005255 for 4
