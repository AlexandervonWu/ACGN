var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv18 {
always (all f:File | f in Protected implies (f in Trash) releases (f in Protected))
}

pred inv18c {
	always all f : Protected | f in Trash releases f in Protected
}

check correct { inv18 <=> inv18c}
pred under { inv18 and !inv18c}
pred over { !inv18 and inv18c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000790 { (inv18 and ((no CapBenchA and some capBenchR) and some capBenchR)) }
pred cap000790c { ((inv18 and ((no CapBenchA and some capBenchR) and some capBenchR)) and (inv18 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap000790 { cap000790 iff cap000790c }
check CapBenchEquivalent_cap000790 for 4
