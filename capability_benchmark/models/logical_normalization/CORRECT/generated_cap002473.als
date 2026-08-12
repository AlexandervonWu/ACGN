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

pred cap002473 { no x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002473c { all x: CapBenchA | not (x->x in capBenchR and (inv7 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002473 { cap002473 iff cap002473c }
check CapBenchEquivalent_cap002473 for 4
