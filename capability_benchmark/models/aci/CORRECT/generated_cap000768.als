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

pred cap000768 { (some ((CapBenchA.capBenchR).capBenchR) and (inv11 and ((some capBenchR and some CapBenchB) or some capBenchR))) }
pred cap000768c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv11 and ((some capBenchR and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000768 { cap000768 iff cap000768c }
check CapBenchEquivalent_cap000768 for 4
