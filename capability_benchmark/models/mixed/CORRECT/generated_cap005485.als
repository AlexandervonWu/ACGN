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

pred cap005485 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv18 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
pred cap005485c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and no CapBenchA)) or (not (inv18 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005485 { cap005485 iff cap005485c }
check CapBenchEquivalent_cap005485 for 4
