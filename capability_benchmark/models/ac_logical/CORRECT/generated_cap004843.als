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

pred cap004843 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) and ((some capBenchR and some CapBenchA) or some CapBenchA)) }
pred cap004843c { ((not ((some capBenchR and some CapBenchA) or some CapBenchA)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap004843 { cap004843 iff cap004843c }
check CapBenchEquivalent_cap004843 for 4
