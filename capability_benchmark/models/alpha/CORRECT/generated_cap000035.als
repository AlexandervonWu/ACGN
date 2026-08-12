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

pred cap000035 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap000035c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap000035 { cap000035 iff cap000035c }
check CapBenchEquivalent_cap000035 for 4
