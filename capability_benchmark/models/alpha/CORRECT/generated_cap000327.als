var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
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

pred cap000327 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap000327c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000327 { cap000327 iff cap000327c }
check CapBenchEquivalent_cap000327 for 4
