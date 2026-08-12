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

pred cap000734 { ((inv19 and ((no CapBenchA and some capBenchS) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and ((some capBenchS or some CapBenchA) or some CapBenchB)) }
pred cap000734c { (((some capBenchS or some CapBenchA) or some CapBenchB) and (inv19 and ((no CapBenchA and some capBenchS) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000734 { cap000734 iff cap000734c }
check CapBenchEquivalent_cap000734 for 4
