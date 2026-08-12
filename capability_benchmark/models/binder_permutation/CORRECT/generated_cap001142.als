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

pred cap001142 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) }
pred cap001142c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap001142 { cap001142 iff cap001142c }
check CapBenchEquivalent_cap001142 for 4
