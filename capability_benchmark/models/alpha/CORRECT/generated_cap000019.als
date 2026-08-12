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

pred cap000019 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap000019c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000019 { cap000019 iff cap000019c }
check CapBenchEquivalent_cap000019 for 4
