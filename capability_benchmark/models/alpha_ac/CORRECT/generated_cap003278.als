sig Node {
	adj : set Node
}
pred inv7 {
all n:Node | Node in n.*adj
}

pred inv7c {
	all n:Node | Node = n.*adj
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003278 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003278c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003278 { cap003278 iff cap003278c }
check CapBenchEquivalent_cap003278 for 4
