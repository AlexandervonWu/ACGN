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

pred cap004937 { not ((inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchR) and some CapBenchB)) }
pred cap004937c { ((not ((no CapBenchA and some capBenchR) and some CapBenchB)) or (not (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004937 { cap004937 iff cap004937c }
check CapBenchEquivalent_cap004937 for 4
