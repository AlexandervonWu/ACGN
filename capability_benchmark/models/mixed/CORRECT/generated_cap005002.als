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

pred cap005002 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap005002c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) or (not (inv9 and ((no CapBenchA and some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005002 { cap005002 iff cap005002c }
check CapBenchEquivalent_cap005002 for 4
