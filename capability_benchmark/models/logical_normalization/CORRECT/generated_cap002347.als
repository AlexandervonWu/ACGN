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

pred cap002347 { no x: CapBenchA | (x->x in capBenchR and (inv9 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap002347c { all x: CapBenchA | not (x->x in capBenchR and (inv9 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002347 { cap002347 iff cap002347c }
check CapBenchEquivalent_cap002347 for 4
