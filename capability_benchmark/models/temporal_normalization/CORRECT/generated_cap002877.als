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

pred cap002877 { not (((inv19 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) since (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
pred cap002877c { ((not (inv19 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap002877 { cap002877 iff cap002877c }
check CapBenchEquivalent_cap002877 for 4
