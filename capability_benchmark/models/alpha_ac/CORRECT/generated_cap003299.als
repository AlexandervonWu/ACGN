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

pred cap003299 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchR)) and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003299c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap003299 { cap003299 iff cap003299c }
check CapBenchEquivalent_cap003299 for 4
