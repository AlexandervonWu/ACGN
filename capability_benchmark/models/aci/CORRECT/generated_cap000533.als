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

pred cap000533 { (inv2 and ((some CapBenchB or some capBenchR) or some CapBenchA)) }
pred cap000533c { ((inv2 and ((some CapBenchB or some capBenchR) or some CapBenchA)) or (inv2 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap000533 { cap000533 iff cap000533c }
check CapBenchEquivalent_cap000533 for 4
