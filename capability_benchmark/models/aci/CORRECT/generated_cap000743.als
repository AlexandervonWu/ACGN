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

pred cap000743 { (inv19 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap000743c { ((inv19 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) or (inv19 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap000743 { cap000743 iff cap000743c }
check CapBenchEquivalent_cap000743 for 4
