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

pred cap004660 { not ((inv12 and ((some CapBenchA and some capBenchR) or no CapBenchA)) and ((some capBenchS or some CapBenchB) or some capBenchS)) }
pred cap004660c { ((not ((some capBenchS or some CapBenchB) or some capBenchS)) or (not (inv12 and ((some CapBenchA and some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004660 { cap004660 iff cap004660c }
check CapBenchEquivalent_cap004660 for 4
