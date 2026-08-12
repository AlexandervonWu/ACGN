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

pred cap003120 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some capBenchS or some capBenchR) or some capBenchR)) }
pred cap003120c { all renamed: CapBenchA | (((some capBenchS or some capBenchR) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003120 { cap003120 iff cap003120c }
check CapBenchEquivalent_cap003120 for 4
