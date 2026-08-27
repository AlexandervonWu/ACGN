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

pred cap000822 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv11 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap000822c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv11 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000822 { cap000822 iff cap000822c }
check CapBenchEquivalent_cap000822 for 4
