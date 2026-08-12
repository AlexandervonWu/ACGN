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

pred cap004610 { not ((inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB)) and ((no CapBenchB or no CapBenchB) and some capBenchR)) }
pred cap004610c { ((not ((no CapBenchB or no CapBenchB) and some capBenchR)) or (not (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004610 { cap004610 iff cap004610c }
check CapBenchEquivalent_cap004610 for 4
