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

pred cap002086 { ((inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) implies ((no CapBenchB or some CapBenchA) and some capBenchR)) }
pred cap002086c { ((not (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) or ((no CapBenchB or some CapBenchA) and some capBenchR)) }
assert CapBenchEquivalent_cap002086 { cap002086 iff cap002086c }
check CapBenchEquivalent_cap002086 for 4
