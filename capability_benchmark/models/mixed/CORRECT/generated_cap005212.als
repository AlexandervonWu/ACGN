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

pred cap005212 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some capBenchR and no CapBenchA) or no CapBenchB)) and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005212c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv9 and ((some capBenchR and no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005212 { cap005212 iff cap005212c }
check CapBenchEquivalent_cap005212 for 4
