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

pred cap002648 { not (((inv2 and ((some capBenchR and no CapBenchA) or no CapBenchA))) until (((some CapBenchB or some CapBenchA) or some capBenchS))) }
pred cap002648c { ((not (inv2 and ((some capBenchR and no CapBenchA) or no CapBenchA))) releases (not ((some CapBenchB or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002648 { cap002648 iff cap002648c }
check CapBenchEquivalent_cap002648 for 4
