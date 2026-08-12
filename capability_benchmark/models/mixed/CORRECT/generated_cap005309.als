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

pred cap005309 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005309c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap005309 { cap005309 iff cap005309c }
check CapBenchEquivalent_cap005309 for 4
