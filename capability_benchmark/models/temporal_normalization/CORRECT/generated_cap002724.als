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

pred cap002724 { not historically ((inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
pred cap002724c { once (not (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap002724 { cap002724 iff cap002724c }
check CapBenchEquivalent_cap002724 for 4
