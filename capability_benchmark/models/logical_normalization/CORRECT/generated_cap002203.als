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

pred cap002203 { no x: CapBenchA | (x->x in capBenchR and (inv13 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap002203c { all x: CapBenchA | not (x->x in capBenchR and (inv13 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002203 { cap002203 iff cap002203c }
check CapBenchEquivalent_cap002203 for 4
