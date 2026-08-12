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

pred cap004695 { not ((inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap004695c { ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv2 and ((no CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004695 { cap004695 iff cap004695c }
check CapBenchEquivalent_cap004695 for 4
