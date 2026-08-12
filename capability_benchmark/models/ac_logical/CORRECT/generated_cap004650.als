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

pred cap004650 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((no CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap004650c { ((not ((no CapBenchB or some CapBenchA) and some capBenchS)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004650 { cap004650 iff cap004650c }
check CapBenchEquivalent_cap004650 for 4
