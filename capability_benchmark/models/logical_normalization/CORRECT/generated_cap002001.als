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

pred cap002001 { not ((inv12 and ((some CapBenchB or some CapBenchA) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) }
pred cap002001c { ((not (inv12 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap002001 { cap002001 iff cap002001c }
check CapBenchEquivalent_cap002001 for 4
