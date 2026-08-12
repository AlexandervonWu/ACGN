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

pred cap004725 { not ((inv11 and ((some CapBenchB or some capBenchR) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004725c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv11 and ((some CapBenchB or some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004725 { cap004725 iff cap004725c }
check CapBenchEquivalent_cap004725 for 4
