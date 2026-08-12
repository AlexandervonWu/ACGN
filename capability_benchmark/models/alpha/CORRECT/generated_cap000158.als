var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12 {
eventually (some f : Trash | always f in Trash)
}

pred inv12c {
	eventually some f : File | always f in Trash
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000158 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
pred cap000158c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000158 { cap000158 iff cap000158c }
check CapBenchEquivalent_cap000158 for 4
