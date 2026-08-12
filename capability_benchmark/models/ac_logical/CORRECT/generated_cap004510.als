var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f : File | f not in Protected implies after f in Protected
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

pred cap004510 { not ((inv11 and ((no CapBenchA and some CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap004510c { ((not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv11 and ((no CapBenchA and some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004510 { cap004510 iff cap004510c }
check CapBenchEquivalent_cap004510 for 4
