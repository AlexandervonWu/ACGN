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

pred cap002160 { not (all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and some capBenchR) or no CapBenchA)))) }
pred cap002160c { some x: CapBenchA | not (x->x in capBenchR and (inv7 and ((some CapBenchA and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap002160 { cap002160 iff cap002160c }
check CapBenchEquivalent_cap002160 for 4
