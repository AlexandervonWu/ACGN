var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004551 { not ((inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((some CapBenchA and some capBenchR) or no CapBenchB)) }
pred cap004551c { ((not ((some CapBenchA and some capBenchR) or no CapBenchB)) or (not (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004551 { cap004551 iff cap004551c }
check CapBenchEquivalent_cap004551 for 4
