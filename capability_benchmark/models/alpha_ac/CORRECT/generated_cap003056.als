var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually (some f:File | f in Trash)
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

pred cap003056 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some capBenchS or some capBenchR) or no CapBenchB)) }
pred cap003056c { all renamed: CapBenchA | (((some capBenchS or some capBenchR) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003056 { cap003056 iff cap003056c }
check CapBenchEquivalent_cap003056 for 4
