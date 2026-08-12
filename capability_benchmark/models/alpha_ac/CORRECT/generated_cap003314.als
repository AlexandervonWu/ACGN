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

pred cap003314 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003314c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003314 { cap003314 iff cap003314c }
check CapBenchEquivalent_cap003314 for 4
