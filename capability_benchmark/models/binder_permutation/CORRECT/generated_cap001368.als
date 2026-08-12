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

pred cap001368 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap001368c { all a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap001368 { cap001368 iff cap001368c }
check CapBenchEquivalent_cap001368 for 4
