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

pred cap002946 { not historically ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002946c { once (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002946 { cap002946 iff cap002946c }
check CapBenchEquivalent_cap002946 for 4
