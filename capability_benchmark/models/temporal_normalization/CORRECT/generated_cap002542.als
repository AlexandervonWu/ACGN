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

pred cap002542 { not always ((inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap002542c { eventually (not (inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap002542 { cap002542 iff cap002542c }
check CapBenchEquivalent_cap002542 for 4
