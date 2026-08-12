var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
historically (no Trash and no Protected)
}

pred inv1c {
	no Trash + Protected
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000018 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap000018c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000018 { cap000018 iff cap000018c }
check CapBenchEquivalent_cap000018 for 4
