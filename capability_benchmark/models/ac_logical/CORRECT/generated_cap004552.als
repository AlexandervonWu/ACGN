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

pred cap004552 { not ((inv13 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some CapBenchB or some capBenchR) or no CapBenchB)) }
pred cap004552c { ((not ((some CapBenchB or some capBenchR) or no CapBenchB)) or (not (inv13 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004552 { cap004552 iff cap004552c }
check CapBenchEquivalent_cap004552 for 4
