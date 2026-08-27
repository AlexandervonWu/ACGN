var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : (File&Trash) | once f not in Trash
}

pred inv13c {
	always (all f:Trash | once f not in Trash)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000792 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv13 and ((some capBenchR and some capBenchR) or some capBenchR))) }
pred cap000792c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv13 and ((some capBenchR and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap000792 { cap000792 iff cap000792c }
check CapBenchEquivalent_cap000792 for 4
