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

pred cap002879 { not eventually ((inv9 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap002879c { always (not (inv9 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002879 { cap002879 iff cap002879c }
check CapBenchEquivalent_cap002879 for 4
