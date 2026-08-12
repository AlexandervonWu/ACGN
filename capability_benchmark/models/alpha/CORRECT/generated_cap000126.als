var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File

some File'
}

pred inv2c {
	no File
  	some File'
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000126 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap000126c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000126 { cap000126 iff cap000126c }
check CapBenchEquivalent_cap000126 for 4
