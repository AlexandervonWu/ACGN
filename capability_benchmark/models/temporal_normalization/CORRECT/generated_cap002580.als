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

pred cap002580 { not historically ((inv11 and ((some CapBenchA and no CapBenchA) or some CapBenchB))) }
pred cap002580c { once (not (inv11 and ((some CapBenchA and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002580 { cap002580 iff cap002580c }
check CapBenchEquivalent_cap002580 for 4
