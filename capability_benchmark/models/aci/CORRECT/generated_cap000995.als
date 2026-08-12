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

pred cap000995 { (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000995c { ((inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000995 { cap000995 iff cap000995c }
check CapBenchEquivalent_cap000995 for 4
