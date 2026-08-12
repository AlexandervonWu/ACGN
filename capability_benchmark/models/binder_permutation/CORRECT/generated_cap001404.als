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

pred cap001404 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001404c { all a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001404 { cap001404 iff cap001404c }
check CapBenchEquivalent_cap001404 for 4
