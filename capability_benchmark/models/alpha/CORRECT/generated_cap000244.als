sig Node {
	adj : set Node
}
pred inv1 {
all n,m: Node | m in n.adj => n in m.adj
}

pred inv1c {
	adj = ~adj
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000244 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap000244c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap000244 { cap000244 iff cap000244c }
check CapBenchEquivalent_cap000244 for 4
