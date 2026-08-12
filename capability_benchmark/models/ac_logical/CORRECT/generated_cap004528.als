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

pred cap004528 { not ((inv13 and ((some capBenchR and no CapBenchB) or some CapBenchA)) and ((some CapBenchB or some CapBenchB) or no CapBenchB)) }
pred cap004528c { ((not ((some CapBenchB or some CapBenchB) or no CapBenchB)) or (not (inv13 and ((some capBenchR and no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004528 { cap004528 iff cap004528c }
check CapBenchEquivalent_cap004528 for 4
