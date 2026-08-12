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

pred cap004096 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv13 and ((some CapBenchA and some capBenchR) or some CapBenchB))) }
pred cap004096c { some a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((some CapBenchA and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap004096 { cap004096 iff cap004096c }
check CapBenchEquivalent_cap004096 for 4
