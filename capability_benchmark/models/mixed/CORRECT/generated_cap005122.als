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

pred cap005122 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv12 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
pred cap005122c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) or (not (inv12 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005122 { cap005122 iff cap005122c }
check CapBenchEquivalent_cap005122 for 4
