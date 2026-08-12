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

pred cap001721 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
pred cap001721c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((some capBenchS or no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001721 { cap001721 iff cap001721c }
check CapBenchEquivalent_cap001721 for 4
