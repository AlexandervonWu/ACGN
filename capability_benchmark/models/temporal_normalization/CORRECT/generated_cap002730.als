var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12 {
eventually (some f : Trash | always f in Trash)
}

pred inv12c {
	eventually some f : File | always f in Trash
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002730 { not historically ((inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
pred cap002730c { once (not (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap002730 { cap002730 iff cap002730c }
check CapBenchEquivalent_cap002730 for 4
