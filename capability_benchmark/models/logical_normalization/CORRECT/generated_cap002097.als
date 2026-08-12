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

pred cap002097 { not ((inv11 and ((some CapBenchB or some capBenchR) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) }
pred cap002097c { ((not (inv11 and ((some CapBenchB or some capBenchR) or some CapBenchB))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002097 { cap002097 iff cap002097c }
check CapBenchEquivalent_cap002097 for 4
