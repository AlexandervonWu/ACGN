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

pred cap002568 { not historically ((inv19 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap002568c { once (not (inv19 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002568 { cap002568 iff cap002568c }
check CapBenchEquivalent_cap002568 for 4
