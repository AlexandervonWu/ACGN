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

pred cap002331 { not ((inv2 and ((no CapBenchB or some CapBenchB) and some capBenchS)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002331c { ((not (inv2 and ((no CapBenchB or some CapBenchB) and some capBenchS))) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002331 { cap002331 iff cap002331c }
check CapBenchEquivalent_cap002331 for 4
