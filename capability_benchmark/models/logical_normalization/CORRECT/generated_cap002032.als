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

pred cap002032 { ((inv19 and ((some CapBenchA and some capBenchR) or some CapBenchA)) implies ((some capBenchS or some CapBenchB) or no CapBenchB)) }
pred cap002032c { ((not (inv19 and ((some CapBenchA and some capBenchR) or some CapBenchA))) or ((some capBenchS or some CapBenchB) or no CapBenchB)) }
assert CapBenchEquivalent_cap002032 { cap002032 iff cap002032c }
check CapBenchEquivalent_cap002032 for 4
