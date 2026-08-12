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

pred cap003244 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003244c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv7 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap003244 { cap003244 iff cap003244c }
check CapBenchEquivalent_cap003244 for 4
