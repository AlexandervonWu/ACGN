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

pred cap003479 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and some CapBenchB) or no CapBenchA)) }
pred cap003479c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003479 { cap003479 iff cap003479c }
check CapBenchEquivalent_cap003479 for 4
