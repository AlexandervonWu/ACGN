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

pred cap002259 { not ((inv12 and ((no CapBenchB or some CapBenchA) and some capBenchR)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002259c { ((not (inv12 and ((no CapBenchB or some CapBenchA) and some capBenchR))) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002259 { cap002259 iff cap002259c }
check CapBenchEquivalent_cap002259 for 4
