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

pred cap005437 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
pred cap005437c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and some CapBenchB)) or (not (inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005437 { cap005437 iff cap005437c }
check CapBenchEquivalent_cap005437 for 4
