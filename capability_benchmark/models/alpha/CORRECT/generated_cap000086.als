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

pred cap000086 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
pred cap000086c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000086 { cap000086 iff cap000086c }
check CapBenchEquivalent_cap000086 for 4
