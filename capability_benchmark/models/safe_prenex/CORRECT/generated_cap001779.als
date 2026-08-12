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

pred cap001779 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap001779c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001779 { cap001779 iff cap001779c }
check CapBenchEquivalent_cap001779 for 4
