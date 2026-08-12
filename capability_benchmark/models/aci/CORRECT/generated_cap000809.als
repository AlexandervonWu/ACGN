var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f : File | f not in Protected implies after f in Protected
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000809 { (inv11 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap000809c { ((inv11 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (inv11 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap000809 { cap000809 iff cap000809c }
check CapBenchEquivalent_cap000809 for 4
