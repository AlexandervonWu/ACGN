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

pred cap003160 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchA)) and ((some capBenchS or some CapBenchB) or some capBenchS)) }
pred cap003160c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap003160 { cap003160 iff cap003160c }
check CapBenchEquivalent_cap003160 for 4
