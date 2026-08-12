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

pred cap000704 { ((inv9 and ((some capBenchR and some CapBenchB) or no CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) }
pred cap000704c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA) and (inv9 and ((some capBenchR and some CapBenchB) or no CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
assert CapBenchEquivalent_cap000704 { cap000704 iff cap000704c }
check CapBenchEquivalent_cap000704 for 4
