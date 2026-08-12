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

pred cap000807 { ((inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) }
pred cap000807c { (((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA) or (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap000807 { cap000807 iff cap000807c }
check CapBenchEquivalent_cap000807 for 4
