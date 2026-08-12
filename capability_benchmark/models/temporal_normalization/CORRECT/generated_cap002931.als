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

pred cap002931 { not (((inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) since (((some capBenchR and no CapBenchB) or some CapBenchB))) }
pred cap002931c { ((not (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((some capBenchR and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002931 { cap002931 iff cap002931c }
check CapBenchEquivalent_cap002931 for 4
