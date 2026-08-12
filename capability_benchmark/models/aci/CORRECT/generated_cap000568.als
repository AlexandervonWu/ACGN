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

pred cap000568 { (inv13 and ((some capBenchR and some CapBenchA) or some CapBenchB)) }
pred cap000568c { ((inv13 and ((some capBenchR and some CapBenchA) or some CapBenchB)) and (inv13 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000568 { cap000568 iff cap000568c }
check CapBenchEquivalent_cap000568 for 4
