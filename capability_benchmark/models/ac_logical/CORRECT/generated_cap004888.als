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

pred cap004888 { not ((inv11 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap004888c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (not (inv11 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004888 { cap004888 iff cap004888c }
check CapBenchEquivalent_cap004888 for 4
