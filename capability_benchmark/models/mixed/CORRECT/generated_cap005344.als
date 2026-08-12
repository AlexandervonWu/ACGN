var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19 {
always all f : Protected | f in Protected until f in Trash
}

pred inv19c {
	always all f : Protected | f in Protected until f in Trash
}

check correct { inv19 <=> inv19c}
pred under { inv19 and !inv19c}
pred over { !inv19 and inv19c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005344 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv19 and ((some CapBenchA and no CapBenchB) or some capBenchS)) and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
pred cap005344c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or some CapBenchA)) or (not (inv19 and ((some CapBenchA and no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005344 { cap005344 iff cap005344c }
check CapBenchEquivalent_cap005344 for 4
