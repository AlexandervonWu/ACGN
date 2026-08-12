var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
historically no File and after some File
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

pred cap002416 { ((inv2 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) implies ((some capBenchS or some CapBenchB) or some CapBenchB)) }
pred cap002416c { ((not (inv2 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) or ((some capBenchS or some CapBenchB) or some CapBenchB)) }
assert CapBenchEquivalent_cap002416 { cap002416 iff cap002416c }
check CapBenchEquivalent_cap002416 for 4
