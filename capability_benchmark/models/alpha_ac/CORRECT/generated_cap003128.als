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

pred cap003128 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((some CapBenchA and some CapBenchA) or no CapBenchA)) and ((some capBenchS or some capBenchS) or some capBenchR)) }
pred cap003128c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or some capBenchR) and renamed->renamed in capBenchR and (inv13 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003128 { cap003128 iff cap003128c }
check CapBenchEquivalent_cap003128 for 4
