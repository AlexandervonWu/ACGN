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

pred cap003037 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchS or some capBenchR) or some CapBenchA)) and ((no CapBenchA and no CapBenchA) and no CapBenchB)) }
pred cap003037c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap003037 { cap003037 iff cap003037c }
check CapBenchEquivalent_cap003037 for 4
