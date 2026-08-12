var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005088 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchB)) and ((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap005088c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or some capBenchR)) or (not (inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005088 { cap005088 iff cap005088c }
check CapBenchEquivalent_cap005088 for 4
