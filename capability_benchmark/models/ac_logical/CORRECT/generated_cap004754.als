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

pred cap004754 { not ((inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004754c { ((not ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004754 { cap004754 iff cap004754c }
check CapBenchEquivalent_cap004754 for 4
