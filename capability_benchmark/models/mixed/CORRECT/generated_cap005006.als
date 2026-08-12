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

pred cap005006 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap005006c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005006 { cap005006 iff cap005006c }
check CapBenchEquivalent_cap005006 for 4
