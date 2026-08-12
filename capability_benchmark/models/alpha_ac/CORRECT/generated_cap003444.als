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

pred cap003444 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some capBenchS) or some CapBenchB)) }
pred cap003444c { all renamed: CapBenchA | (((some CapBenchB or some capBenchS) or some CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003444 { cap003444 iff cap003444c }
check CapBenchEquivalent_cap003444 for 4
