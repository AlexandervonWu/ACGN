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

pred cap005158 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap005158c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchB) and some capBenchS)) or (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005158 { cap005158 iff cap005158c }
check CapBenchEquivalent_cap005158 for 4
