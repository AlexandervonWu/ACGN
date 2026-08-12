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

pred cap004814 { not ((inv12 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004814c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv12 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004814 { cap004814 iff cap004814c }
check CapBenchEquivalent_cap004814 for 4
