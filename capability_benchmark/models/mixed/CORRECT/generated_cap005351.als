var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv18 {
always (all f:File | f in Protected implies (f in Trash) releases (f in Protected))
}

pred inv18c {
	always all f : Protected | f in Trash releases f in Protected
}

check correct { inv18 <=> inv18c}
pred under { inv18 and !inv18c}
pred over { !inv18 and inv18c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005351 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv18 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) and ((some capBenchR and some CapBenchB) or some CapBenchA))) }
pred cap005351c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchB) or some CapBenchA)) or (not (inv18 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005351 { cap005351 iff cap005351c }
check CapBenchEquivalent_cap005351 for 4
