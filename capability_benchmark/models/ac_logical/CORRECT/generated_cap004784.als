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

pred cap004784 { not ((inv12 and ((some capBenchR and no CapBenchB) or some capBenchR)) and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004784c { ((not ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv12 and ((some capBenchR and no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004784 { cap004784 iff cap004784c }
check CapBenchEquivalent_cap004784 for 4
