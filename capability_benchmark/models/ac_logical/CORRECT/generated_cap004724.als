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

pred cap004724 { not ((inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB)) and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004724c { ((not ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004724 { cap004724 iff cap004724c }
check CapBenchEquivalent_cap004724 for 4
