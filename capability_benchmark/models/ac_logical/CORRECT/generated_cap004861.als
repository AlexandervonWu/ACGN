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

pred cap004861 { not ((inv2 and ((some CapBenchB or some capBenchS) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) }
pred cap004861c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) or (not (inv2 and ((some CapBenchB or some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap004861 { cap004861 iff cap004861c }
check CapBenchEquivalent_cap004861 for 4
