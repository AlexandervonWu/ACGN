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

pred cap002278 { ((inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) implies ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002278c { ((not (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) or ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002278 { cap002278 iff cap002278c }
check CapBenchEquivalent_cap002278 for 4
