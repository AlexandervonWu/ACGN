var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : (File&Trash) | once f not in Trash
}

pred inv13c {
	always (all f:Trash | once f not in Trash)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004680 { not ((inv13 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some CapBenchB or some capBenchR) or some capBenchS)) }
pred cap004680c { ((not ((some CapBenchB or some capBenchR) or some capBenchS)) or (not (inv13 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004680 { cap004680 iff cap004680c }
check CapBenchEquivalent_cap004680 for 4
