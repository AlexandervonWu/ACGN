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

pred cap005072 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv13 and ((some CapBenchA and some CapBenchB) or some CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap005072c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv13 and ((some CapBenchA and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005072 { cap005072 iff cap005072c }
check CapBenchEquivalent_cap005072 for 4
