var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually (some f:File | f in Trash)
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000780 { (some ((CapBenchA.capBenchR).capBenchR) and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap000780c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000780 { cap000780 iff cap000780c }
check CapBenchEquivalent_cap000780 for 4
