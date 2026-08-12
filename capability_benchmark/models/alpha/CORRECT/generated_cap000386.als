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

pred cap000386 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000386c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000386 { cap000386 iff cap000386c }
check CapBenchEquivalent_cap000386 for 4
