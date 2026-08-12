sig Node {
	adj : set Node
}
pred inv7 {
all n1,n2:Node | n2 in n1.*adj
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

pred cap004456 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004456c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004456 { cap004456 iff cap004456c }
check CapBenchEquivalent_cap004456 for 4
