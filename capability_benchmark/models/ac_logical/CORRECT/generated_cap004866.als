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

pred cap004866 { not ((inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) and ((no CapBenchB or no CapBenchB) and some CapBenchA)) }
pred cap004866c { ((not ((no CapBenchB or no CapBenchB) and some CapBenchA)) or (not (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap004866 { cap004866 iff cap004866c }
check CapBenchEquivalent_cap004866 for 4
