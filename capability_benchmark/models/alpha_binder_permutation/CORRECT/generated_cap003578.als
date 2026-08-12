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

pred cap003578 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
pred cap003578c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003578 { cap003578 iff cap003578c }
check CapBenchEquivalent_cap003578 for 4
