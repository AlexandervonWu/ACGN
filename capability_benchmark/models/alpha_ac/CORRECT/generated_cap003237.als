var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
historically no File and after some File
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

pred cap003237 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchB)) and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003237c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap003237 { cap003237 iff cap003237c }
check CapBenchEquivalent_cap003237 for 4
