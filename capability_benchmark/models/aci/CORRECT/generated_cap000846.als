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

pred cap000846 { (some ((CapBenchA.capBenchR).capBenchR) and (inv9 and ((no CapBenchA and no CapBenchB) and some capBenchS))) }
pred cap000846c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv9 and ((no CapBenchA and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000846 { cap000846 iff cap000846c }
check CapBenchEquivalent_cap000846 for 4
