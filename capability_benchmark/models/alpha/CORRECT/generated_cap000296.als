var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : File | f in Trash implies once f not in Trash
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

pred cap000296 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv13 and ((some CapBenchA and some capBenchS) or some capBenchR))) }
pred cap000296c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv13 and ((some CapBenchA and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap000296 { cap000296 iff cap000296c }
check CapBenchEquivalent_cap000296 for 4
