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

pred cap004042 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap004042c { some a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap004042 { cap004042 iff cap004042c }
check CapBenchEquivalent_cap004042 for 4
