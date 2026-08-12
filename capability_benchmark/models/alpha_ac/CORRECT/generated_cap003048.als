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

pred cap003048 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some capBenchS or no CapBenchB) or no CapBenchB)) }
pred cap003048c { all renamed: CapBenchA | (((some capBenchS or no CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap003048 { cap003048 iff cap003048c }
check CapBenchEquivalent_cap003048 for 4
