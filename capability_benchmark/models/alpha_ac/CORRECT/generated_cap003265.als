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

pred cap003265 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchB or some CapBenchB) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003265c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv9 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003265 { cap003265 iff cap003265c }
check CapBenchEquivalent_cap003265 for 4
