var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9 {
always no Trash & Protected
}

pred inv9c {
	always no Protected & Trash
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000282 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap000282c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv9 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000282 { cap000282 iff cap000282c }
check CapBenchEquivalent_cap000282 for 4
