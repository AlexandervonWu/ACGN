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

pred cap004542 { not ((inv19 and ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) }
pred cap004542c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) or (not (inv19 and ((no CapBenchA and some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004542 { cap004542 iff cap004542c }
check CapBenchEquivalent_cap004542 for 4
