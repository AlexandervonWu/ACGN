var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2 {
no File

some File'
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

pred cap002047 { no x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap002047c { all x: CapBenchA | not (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap002047 { cap002047 iff cap002047c }
check CapBenchEquivalent_cap002047 for 4
