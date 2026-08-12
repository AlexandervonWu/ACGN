var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv18 {
always (all f:File | f in Protected implies (f in Trash) releases (f in Protected))
}

pred inv18c {
	always all f : Protected | f in Trash releases f in Protected
}

check correct { inv18 <=> inv18c}
pred under { inv18 and !inv18c}
pred over { !inv18 and inv18c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000370 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv18 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap000370c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv18 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap000370 { cap000370 iff cap000370c }
check CapBenchEquivalent_cap000370 for 4
