var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4 {
eventually some Trash
}

pred inv4c {
	eventually some Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002569 { not once ((inv4 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
pred cap002569c { historically (not (inv4 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002569 { cap002569 iff cap002569c }
check CapBenchEquivalent_cap002569 for 4
