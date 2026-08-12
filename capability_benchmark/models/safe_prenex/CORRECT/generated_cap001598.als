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

pred cap001598 { ((some x: CapBenchA | x->x in capBenchR) and (inv12 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
pred cap001598c { (some x: CapBenchA | (x->x in capBenchR and (inv12 and ((no CapBenchA and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001598 { cap001598 iff cap001598c }
check CapBenchEquivalent_cap001598 for 4
