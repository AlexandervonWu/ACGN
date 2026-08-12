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

pred cap000540 { (some ((CapBenchA.capBenchR).capBenchR) and (inv11 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
pred cap000540c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv11 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap000540 { cap000540 iff cap000540c }
check CapBenchEquivalent_cap000540 for 4
