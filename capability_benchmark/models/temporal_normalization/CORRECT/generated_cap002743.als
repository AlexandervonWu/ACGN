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

pred cap002743 { not once ((inv9 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap002743c { historically (not (inv9 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap002743 { cap002743 iff cap002743c }
check CapBenchEquivalent_cap002743 for 4
