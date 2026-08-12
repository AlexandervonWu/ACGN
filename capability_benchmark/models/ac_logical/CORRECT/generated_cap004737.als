var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1 {
historically (no Trash and no Protected)
}

pred inv1c {
	no Trash + Protected
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004737 { not ((inv1 and ((some capBenchS or some capBenchS) or no CapBenchB)) and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004737c { ((not ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some capBenchS or some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004737 { cap004737 iff cap004737c }
check CapBenchEquivalent_cap004737 for 4
