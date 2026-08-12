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

pred cap001344 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
pred cap001344c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001344 { cap001344 iff cap001344c }
check CapBenchEquivalent_cap001344 for 4
