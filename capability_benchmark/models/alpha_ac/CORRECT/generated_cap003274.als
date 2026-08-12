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

pred cap003274 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((no CapBenchA and no CapBenchA) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003274c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv13 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003274 { cap003274 iff cap003274c }
check CapBenchEquivalent_cap003274 for 4
