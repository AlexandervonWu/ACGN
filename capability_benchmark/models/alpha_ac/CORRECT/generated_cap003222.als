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

pred cap003222 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003222c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003222 { cap003222 iff cap003222c }
check CapBenchEquivalent_cap003222 for 4
