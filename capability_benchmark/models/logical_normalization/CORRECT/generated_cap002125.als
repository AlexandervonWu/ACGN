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

pred cap002125 { no x: CapBenchA | (x->x in capBenchR and (inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap002125c { all x: CapBenchA | not (x->x in capBenchR and (inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002125 { cap002125 iff cap002125c }
check CapBenchEquivalent_cap002125 for 4
