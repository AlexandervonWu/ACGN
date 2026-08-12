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

pred cap002522 { not (((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) until (((no CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap002522c { ((not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) releases (not ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002522 { cap002522 iff cap002522c }
check CapBenchEquivalent_cap002522 for 4
