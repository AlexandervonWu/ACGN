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

pred cap004999 { not ((inv11 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some capBenchR) or no CapBenchA)) }
pred cap004999c { ((not ((some CapBenchA and some capBenchR) or no CapBenchA)) or (not (inv11 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004999 { cap004999 iff cap004999c }
check CapBenchEquivalent_cap004999 for 4
