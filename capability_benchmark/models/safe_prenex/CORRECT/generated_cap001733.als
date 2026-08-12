var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always all f:Protected | f not in Trash
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001733 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((some CapBenchB or some capBenchS) or no CapBenchB))) }
pred cap001733c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((some CapBenchB or some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001733 { cap001733 iff cap001733c }
check CapBenchEquivalent_cap001733 for 4
