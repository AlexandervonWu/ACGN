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

pred cap001730 { ((some x: CapBenchA | x->x in capBenchR) and (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
pred cap001730c { (some x: CapBenchA | (x->x in capBenchR and (inv19 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001730 { cap001730 iff cap001730c }
check CapBenchEquivalent_cap001730 for 4
