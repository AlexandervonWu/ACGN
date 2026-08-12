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

pred cap002260 { ((inv3 and ((some capBenchR and some CapBenchA) or some capBenchR)) implies ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002260c { ((not (inv3 and ((some capBenchR and some CapBenchA) or some capBenchR))) or ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002260 { cap002260 iff cap002260c }
check CapBenchEquivalent_cap002260 for 4
