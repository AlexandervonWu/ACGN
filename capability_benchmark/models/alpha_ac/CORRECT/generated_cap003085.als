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

pred cap003085 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchB)) and ((no CapBenchA and some CapBenchA) and some capBenchR)) }
pred cap003085c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003085 { cap003085 iff cap003085c }
check CapBenchEquivalent_cap003085 for 4
