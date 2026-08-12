var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always (all f : File | f not in Protected implies after f in Protected)
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004982 { not ((inv11 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) }
pred cap004982c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) or (not (inv11 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004982 { cap004982 iff cap004982c }
check CapBenchEquivalent_cap004982 for 4
