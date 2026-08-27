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

pred cap000834 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv18 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
pred cap000834c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv18 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000834 { cap000834 iff cap000834c }
check CapBenchEquivalent_cap000834 for 4
