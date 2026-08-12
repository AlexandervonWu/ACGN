var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : File | f in Trash implies once f not in Trash
}

pred inv13c {
	always (all f:Trash | once f not in Trash)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004508 { not ((inv13 and ((some CapBenchA and some CapBenchB) or some CapBenchA)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap004508c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (not (inv13 and ((some CapBenchA and some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004508 { cap004508 iff cap004508c }
check CapBenchEquivalent_cap004508 for 4
