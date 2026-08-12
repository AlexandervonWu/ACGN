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

pred cap003956 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003956c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003956 { cap003956 iff cap003956c }
check CapBenchEquivalent_cap003956 for 4
