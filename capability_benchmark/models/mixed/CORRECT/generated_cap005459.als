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

pred cap005459 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv18 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap005459c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv18 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005459 { cap005459 iff cap005459c }
check CapBenchEquivalent_cap005459 for 4
