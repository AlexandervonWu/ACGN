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

pred cap002069 { ((inv2 and ((some capBenchS or some CapBenchA) or some CapBenchB)) iff ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap002069c { (((not (inv2 and ((some capBenchS or some CapBenchA) or some CapBenchB))) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) or (inv2 and ((some capBenchS or some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap002069 { cap002069 iff cap002069c }
check CapBenchEquivalent_cap002069 for 4
