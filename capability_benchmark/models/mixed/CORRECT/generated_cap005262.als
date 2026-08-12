var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always all f:Protected | f not in Trash
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005262 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005262c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap005262 { cap005262 iff cap005262c }
check CapBenchEquivalent_cap005262 for 4
