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

pred cap002241 { not ((inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002241c { ((not (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002241 { cap002241 iff cap002241c }
check CapBenchEquivalent_cap002241 for 4
