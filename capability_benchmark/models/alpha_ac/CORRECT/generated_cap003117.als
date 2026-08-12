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

pred cap003117 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((no CapBenchA and some capBenchR) and some capBenchR)) }
pred cap003117c { all renamed: CapBenchA | (((no CapBenchA and some capBenchR) and some capBenchR) and renamed->renamed in capBenchR and (inv13 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap003117 { cap003117 iff cap003117c }
check CapBenchEquivalent_cap003117 for 4
