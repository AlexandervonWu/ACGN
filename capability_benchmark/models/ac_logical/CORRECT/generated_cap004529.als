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

pred cap004529 { not ((inv2 and ((some capBenchS or no CapBenchB) or some CapBenchA)) and ((no CapBenchA and some CapBenchB) and no CapBenchB)) }
pred cap004529c { ((not ((no CapBenchA and some CapBenchB) and no CapBenchB)) or (not (inv2 and ((some capBenchS or no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004529 { cap004529 iff cap004529c }
check CapBenchEquivalent_cap004529 for 4
