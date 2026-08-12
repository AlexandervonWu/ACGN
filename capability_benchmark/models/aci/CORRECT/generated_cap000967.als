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

pred cap000967 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv11 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000967c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv11 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000967 { cap000967 iff cap000967c }
check CapBenchEquivalent_cap000967 for 4
