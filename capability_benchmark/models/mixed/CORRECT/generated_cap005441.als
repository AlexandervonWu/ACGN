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

pred cap005441 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
pred cap005441c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) or (not (inv11 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005441 { cap005441 iff cap005441c }
check CapBenchEquivalent_cap005441 for 4
