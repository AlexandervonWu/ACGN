var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
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

pred cap005405 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchA) and some CapBenchB))) }
pred cap005405c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and some CapBenchB)) or (not (inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005405 { cap005405 iff cap005405c }
check CapBenchEquivalent_cap005405 for 4
