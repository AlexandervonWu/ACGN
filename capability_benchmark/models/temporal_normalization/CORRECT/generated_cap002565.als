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

pred cap002565 { not (((inv13 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) since (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
pred cap002565c { ((not (inv13 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap002565 { cap002565 iff cap002565c }
check CapBenchEquivalent_cap002565 for 4
