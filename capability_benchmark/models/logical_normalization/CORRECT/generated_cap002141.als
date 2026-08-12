var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File and after some File
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

pred cap002141 { ((inv2 and ((some capBenchS or some CapBenchB) or no CapBenchA)) iff ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap002141c { (((not (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchA))) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002141 { cap002141 iff cap002141c }
check CapBenchEquivalent_cap002141 for 4
