var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12 {
eventually (some f : Trash | always f in Trash)
}

pred inv12c {
	eventually some f : File | always f in Trash
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003114 { all x: CapBenchA | (x->x in capBenchR and (inv12 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) }
pred cap003114c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv12 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
assert CapBenchEquivalent_cap003114 { cap003114 iff cap003114c }
check CapBenchEquivalent_cap003114 for 4
