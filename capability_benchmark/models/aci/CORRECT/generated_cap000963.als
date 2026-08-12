var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12 {
eventually (some f : Trash | always f in Trash)
}

pred inv12c {
	eventually some f : File | always f in Trash
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000963 { ((inv12 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB) or ((no CapBenchA and some capBenchS) and some capBenchR)) }
pred cap000963c { (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB) or ((no CapBenchA and some capBenchS) and some capBenchR) or (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000963 { cap000963 iff cap000963c }
check CapBenchEquivalent_cap000963 for 4
