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

pred cap004954 { not ((inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap004954c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) or (not (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004954 { cap004954 iff cap004954c }
check CapBenchEquivalent_cap004954 for 4
