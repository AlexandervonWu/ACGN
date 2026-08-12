var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv3 {
always some File
}

pred inv3c {
	always some File
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004732 { not ((inv3 and ((some CapBenchA and some capBenchS) or no CapBenchB)) and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004732c { ((not ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchA and some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004732 { cap004732 iff cap004732c }
check CapBenchEquivalent_cap004732 for 4
