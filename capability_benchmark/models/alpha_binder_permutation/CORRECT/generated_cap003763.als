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

pred cap003763 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap003763c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003763 { cap003763 iff cap003763c }
check CapBenchEquivalent_cap003763 for 4
