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

pred cap002993 { not eventually ((inv13 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002993c { always (not (inv13 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002993 { cap002993 iff cap002993c }
check CapBenchEquivalent_cap002993 for 4
