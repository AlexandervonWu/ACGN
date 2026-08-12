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

pred cap004010 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv12 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
pred cap004010c { some a, b: CapBenchA | (b->a in capBenchR and (inv12 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap004010 { cap004010 iff cap004010c }
check CapBenchEquivalent_cap004010 for 4
