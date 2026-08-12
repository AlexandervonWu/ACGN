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

pred cap000975 { ((inv11 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or ((some CapBenchA and some CapBenchB) or no CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap000975c { (((some CapBenchA and some CapBenchB) or no CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR) or (inv11 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000975 { cap000975 iff cap000975c }
check CapBenchEquivalent_cap000975 for 4
