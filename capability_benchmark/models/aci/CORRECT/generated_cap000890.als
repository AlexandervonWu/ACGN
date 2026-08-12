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

pred cap000890 { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA) and ((some CapBenchB or some capBenchR) or no CapBenchB)) }
pred cap000890c { (((some CapBenchB or some capBenchR) or no CapBenchB) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
assert CapBenchEquivalent_cap000890 { cap000890 iff cap000890c }
check CapBenchEquivalent_cap000890 for 4
