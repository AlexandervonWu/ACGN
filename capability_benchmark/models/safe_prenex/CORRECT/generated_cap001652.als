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

pred cap001652 { ((some x: CapBenchA | x->x in capBenchR) and (inv7 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
pred cap001652c { (some x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001652 { cap001652 iff cap001652c }
check CapBenchEquivalent_cap001652 for 4
