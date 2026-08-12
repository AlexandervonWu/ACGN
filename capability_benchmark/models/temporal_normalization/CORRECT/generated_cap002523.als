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

pred cap002523 { not (((inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) since (((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap002523c { ((not (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) triggered (not ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002523 { cap002523 iff cap002523c }
check CapBenchEquivalent_cap002523 for 4
