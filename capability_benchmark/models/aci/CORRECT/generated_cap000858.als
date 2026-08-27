var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19 {
always all f : Protected | f in Protected until f in Trash
}

pred inv19c {
	always all f : Protected | f in Protected until f in Trash
}

check correct { inv19 <=> inv19c}
pred under { inv19 and !inv19c}
pred over { !inv19 and inv19c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000858 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
pred cap000858c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap000858 { cap000858 iff cap000858c }
check CapBenchEquivalent_cap000858 for 4
