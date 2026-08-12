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

pred cap002475 { not ((inv12 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some CapBenchB) or no CapBenchA)) }
pred cap002475c { ((not (inv12 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) or (not ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002475 { cap002475 iff cap002475c }
check CapBenchEquivalent_cap002475 for 4
