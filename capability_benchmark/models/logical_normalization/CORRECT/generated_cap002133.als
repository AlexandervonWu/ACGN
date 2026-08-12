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

pred cap002133 { not ((inv11 and ((some capBenchS or some CapBenchA) or no CapBenchA)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap002133c { ((not (inv11 and ((some capBenchS or some CapBenchA) or no CapBenchA))) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap002133 { cap002133 iff cap002133c }
check CapBenchEquivalent_cap002133 for 4
