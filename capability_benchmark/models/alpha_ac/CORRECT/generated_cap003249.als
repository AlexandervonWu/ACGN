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

pred cap003249 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003249c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003249 { cap003249 iff cap003249c }
check CapBenchEquivalent_cap003249 for 4
