var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File

some File'
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

pred cap000584 { ((inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB)) and ((some CapBenchB or some CapBenchA) or some capBenchR) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000584c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB)) and ((some CapBenchB or some CapBenchA) or some capBenchR)) }
assert CapBenchEquivalent_cap000584 { cap000584 iff cap000584c }
check CapBenchEquivalent_cap000584 for 4
