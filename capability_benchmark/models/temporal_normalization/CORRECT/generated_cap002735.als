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

pred cap002735 { not eventually ((inv11 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap002735c { always (not (inv11 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap002735 { cap002735 iff cap002735c }
check CapBenchEquivalent_cap002735 for 4
