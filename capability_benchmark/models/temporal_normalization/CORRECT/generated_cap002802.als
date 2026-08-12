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

pred cap002802 { not historically ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR))) }
pred cap002802c { once (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap002802 { cap002802 iff cap002802c }
check CapBenchEquivalent_cap002802 for 4
