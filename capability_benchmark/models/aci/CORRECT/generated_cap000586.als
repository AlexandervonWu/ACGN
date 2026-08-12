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

pred cap000586 { (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) }
pred cap000586c { ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB)) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000586 { cap000586 iff cap000586c }
check CapBenchEquivalent_cap000586 for 4
