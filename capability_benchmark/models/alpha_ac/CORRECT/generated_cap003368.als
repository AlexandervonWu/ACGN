var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
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

pred cap003368 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some capBenchS or no CapBenchB) or some CapBenchA)) }
pred cap003368c { all renamed: CapBenchA | (((some capBenchS or no CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap003368 { cap003368 iff cap003368c }
check CapBenchEquivalent_cap003368 for 4
