var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always all f: (File - Protected) | after f in Protected
}

pred inv11c {
	always File-Protected in Protected'
}

check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002826 { not historically ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS))) }
pred cap002826c { once (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002826 { cap002826 iff cap002826c }
check CapBenchEquivalent_cap002826 for 4
