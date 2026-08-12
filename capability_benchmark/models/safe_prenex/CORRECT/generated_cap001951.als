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

pred cap001951 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001951c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001951 { cap001951 iff cap001951c }
check CapBenchEquivalent_cap001951 for 4
