var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f: (File - Protected) | after f in Protected
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000569 { (inv11 and ((some capBenchS or some CapBenchA) or some CapBenchB)) }
pred cap000569c { ((inv11 and ((some capBenchS or some CapBenchA) or some CapBenchB)) or (inv11 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000569 { cap000569 iff cap000569c }
check CapBenchEquivalent_cap000569 for 4
