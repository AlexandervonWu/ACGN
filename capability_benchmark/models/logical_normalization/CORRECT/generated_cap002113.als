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

pred cap002113 { no x: CapBenchA | (x->x in capBenchR and (inv19 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap002113c { all x: CapBenchA | not (x->x in capBenchR and (inv19 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap002113 { cap002113 iff cap002113c }
check CapBenchEquivalent_cap002113 for 4
