var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19 {
always all f : Protected | f in Protected until f in Trash
}

pred inv19c {
	always all f : Protected | f in Protected until f in Trash
}

check correct { inv19 <=> inv19c}
pred under { inv19 and !inv19c}
pred over { !inv19 and inv19c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001625 { ((all x: CapBenchA | x->x in capBenchR) or (inv19 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap001625c { (all x: CapBenchA | (x->x in capBenchR or (inv19 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001625 { cap001625 iff cap001625c }
check CapBenchEquivalent_cap001625 for 4
