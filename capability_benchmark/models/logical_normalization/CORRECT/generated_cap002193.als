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

pred cap002193 { not ((inv12 and ((some CapBenchB or some CapBenchA) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) }
pred cap002193c { ((not (inv12 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002193 { cap002193 iff cap002193c }
check CapBenchEquivalent_cap002193 for 4
