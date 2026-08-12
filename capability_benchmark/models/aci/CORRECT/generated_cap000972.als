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

pred cap000972 { (some ((CapBenchA.capBenchR).capBenchR) and (inv4 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000972c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv4 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000972 { cap000972 iff cap000972c }
check CapBenchEquivalent_cap000972 for 4
