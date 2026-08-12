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

pred cap005058 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap005058c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) or (not (inv11 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005058 { cap005058 iff cap005058c }
check CapBenchEquivalent_cap005058 for 4
