var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11 {
always (all f : File | f not in Protected implies after f in Protected)
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

pred cap000594 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) }
pred cap000594c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000594 { cap000594 iff cap000594c }
check CapBenchEquivalent_cap000594 for 4
