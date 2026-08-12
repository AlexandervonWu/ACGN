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

pred cap000548 { ((inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some capBenchS or no CapBenchB) or no CapBenchB) and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000548c { (((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some capBenchS or no CapBenchB) or no CapBenchB)) }
assert CapBenchEquivalent_cap000548 { cap000548 iff cap000548c }
check CapBenchEquivalent_cap000548 for 4
