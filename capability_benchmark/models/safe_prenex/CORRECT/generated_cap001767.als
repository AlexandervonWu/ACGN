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

pred cap001767 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap001767c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((no CapBenchB or some CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001767 { cap001767 iff cap001767c }
check CapBenchEquivalent_cap001767 for 4
