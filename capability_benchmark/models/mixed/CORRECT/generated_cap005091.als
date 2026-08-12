var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
historically (no Trash and no Protected)
}

pred inv1c {
	no Trash + Protected
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005091 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB)) and ((some CapBenchA and some CapBenchB) or some capBenchR))) }
pred cap005091c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or some capBenchR)) or (not (inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005091 { cap005091 iff cap005091c }
check CapBenchEquivalent_cap005091 for 4
