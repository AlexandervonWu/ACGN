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

pred cap002129 { ((inv19 and ((some CapBenchB or some CapBenchA) or no CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) }
pred cap002129c { (((not (inv19 and ((some CapBenchB or some CapBenchA) or no CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) or (inv19 and ((some CapBenchB or some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002129 { cap002129 iff cap002129c }
check CapBenchEquivalent_cap002129 for 4
