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

pred cap004885 { not ((inv19 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) }
pred cap004885c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) or (not (inv19 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004885 { cap004885 iff cap004885c }
check CapBenchEquivalent_cap004885 for 4
