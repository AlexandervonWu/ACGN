var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File and after some File
}

pred inv2c {
	no File
  	some File'
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003346 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) }
pred cap003346c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003346 { cap003346 iff cap003346c }
check CapBenchEquivalent_cap003346 for 4
