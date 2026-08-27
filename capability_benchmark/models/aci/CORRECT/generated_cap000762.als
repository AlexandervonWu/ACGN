var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv3 {
always some File
}

pred inv3c {
	always some File
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000762 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
pred cap000762c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000762 { cap000762 iff cap000762c }
check CapBenchEquivalent_cap000762 for 4
