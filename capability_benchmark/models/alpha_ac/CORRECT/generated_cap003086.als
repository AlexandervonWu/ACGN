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

pred cap003086 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) and ((no CapBenchB or some CapBenchA) and some capBenchR)) }
pred cap003086c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003086 { cap003086 iff cap003086c }
check CapBenchEquivalent_cap003086 for 4
