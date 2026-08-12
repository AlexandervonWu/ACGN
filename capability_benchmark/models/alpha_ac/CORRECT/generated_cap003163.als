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

pred cap003163 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA)) and ((some CapBenchA and no CapBenchA) or some capBenchS)) }
pred cap003163c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003163 { cap003163 iff cap003163c }
check CapBenchEquivalent_cap003163 for 4
