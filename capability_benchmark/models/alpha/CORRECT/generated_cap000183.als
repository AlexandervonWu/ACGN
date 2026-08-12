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

pred cap000183 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap000183c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
assert CapBenchEquivalent_cap000183 { cap000183 iff cap000183c }
check CapBenchEquivalent_cap000183 for 4
