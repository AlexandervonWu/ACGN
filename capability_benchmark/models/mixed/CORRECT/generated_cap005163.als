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

pred cap005163 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((no CapBenchB or some capBenchR) and no CapBenchA)) and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
pred cap005163c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchA) or some capBenchS)) or (not (inv11 and ((no CapBenchB or some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005163 { cap005163 iff cap005163c }
check CapBenchEquivalent_cap005163 for 4
