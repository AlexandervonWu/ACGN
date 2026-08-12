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

pred cap005109 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some capBenchS or some capBenchS) or some CapBenchB)) and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap005109c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchB) and some capBenchR)) or (not (inv11 and ((some capBenchS or some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005109 { cap005109 iff cap005109c }
check CapBenchEquivalent_cap005109 for 4
