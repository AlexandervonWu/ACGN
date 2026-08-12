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

pred cap003263 { all x: CapBenchA | (x->x in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003263c { all renamed: CapBenchA | (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv19 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003263 { cap003263 iff cap003263c }
check CapBenchEquivalent_cap003263 for 4
