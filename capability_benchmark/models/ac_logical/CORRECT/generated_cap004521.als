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

pred cap004521 { not ((inv9 and ((some capBenchS or no CapBenchA) or some CapBenchA)) and ((no CapBenchA and some CapBenchA) and no CapBenchB)) }
pred cap004521c { ((not ((no CapBenchA and some CapBenchA) and no CapBenchB)) or (not (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004521 { cap004521 iff cap004521c }
check CapBenchEquivalent_cap004521 for 4
