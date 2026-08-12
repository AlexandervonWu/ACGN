var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : File | f in Trash implies once f not in Trash
}

pred inv13c {
	always (all f:Trash | once f not in Trash)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005102 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap005102c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchA) and some capBenchR)) or (not (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005102 { cap005102 iff cap005102c }
check CapBenchEquivalent_cap005102 for 4
