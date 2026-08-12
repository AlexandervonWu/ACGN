var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : (File&Trash) | once f not in Trash
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

pred cap001282 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap001282c { all a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap001282 { cap001282 iff cap001282c }
check CapBenchEquivalent_cap001282 for 4
