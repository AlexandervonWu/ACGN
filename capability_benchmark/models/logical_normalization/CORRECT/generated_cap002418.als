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

pred cap002418 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002418c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002418 { cap002418 iff cap002418c }
check CapBenchEquivalent_cap002418 for 4
