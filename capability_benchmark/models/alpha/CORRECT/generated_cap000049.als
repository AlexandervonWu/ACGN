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

pred cap000049 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap000049c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap000049 { cap000049 iff cap000049c }
check CapBenchEquivalent_cap000049 for 4
