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

pred cap000998 { ((inv12 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA) and ((some capBenchS or some CapBenchB) or some capBenchS)) }
pred cap000998c { (((some capBenchS or some CapBenchB) or some capBenchS) and (inv12 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap000998 { cap000998 iff cap000998c }
check CapBenchEquivalent_cap000998 for 4
