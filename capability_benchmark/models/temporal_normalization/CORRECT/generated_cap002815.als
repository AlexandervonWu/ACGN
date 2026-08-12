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

pred cap002815 { not once ((inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap002815c { historically (not (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002815 { cap002815 iff cap002815c }
check CapBenchEquivalent_cap002815 for 4
