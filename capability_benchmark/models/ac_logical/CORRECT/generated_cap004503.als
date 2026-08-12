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

pred cap004503 { not ((inv2 and ((no CapBenchB or some CapBenchA) and some CapBenchA)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap004503c { ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (not (inv2 and ((no CapBenchB or some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004503 { cap004503 iff cap004503c }
check CapBenchEquivalent_cap004503 for 4
