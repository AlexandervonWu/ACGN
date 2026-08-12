var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13 {
all f : (File&Trash) | once f not in Trash
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

pred cap004513 { not ((inv13 and ((some capBenchS or some CapBenchB) or some CapBenchA)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap004513c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv13 and ((some capBenchS or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004513 { cap004513 iff cap004513c }
check CapBenchEquivalent_cap004513 for 4
