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

pred cap004684 { not ((inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((some capBenchS or some capBenchR) or some capBenchS)) }
pred cap004684c { ((not ((some capBenchS or some capBenchR) or some capBenchS)) or (not (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004684 { cap004684 iff cap004684c }
check CapBenchEquivalent_cap004684 for 4
