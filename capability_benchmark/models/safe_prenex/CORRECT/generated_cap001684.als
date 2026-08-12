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

pred cap001684 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap001684c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001684 { cap001684 iff cap001684c }
check CapBenchEquivalent_cap001684 for 4
