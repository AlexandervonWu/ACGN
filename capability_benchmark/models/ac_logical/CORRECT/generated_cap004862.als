var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : File | f in Trash implies once f not in Trash
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

pred cap004862 { not ((inv13 and ((no CapBenchA and some capBenchS) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) }
pred cap004862c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) or (not (inv13 and ((no CapBenchA and some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap004862 { cap004862 iff cap004862c }
check CapBenchEquivalent_cap004862 for 4
