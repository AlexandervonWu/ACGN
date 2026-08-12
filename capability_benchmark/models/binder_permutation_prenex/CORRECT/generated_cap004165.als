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

pred cap004165 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv18 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
pred cap004165c { some a, b: CapBenchA | (b->a in capBenchR and (inv18 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap004165 { cap004165 iff cap004165c }
check CapBenchEquivalent_cap004165 for 4
