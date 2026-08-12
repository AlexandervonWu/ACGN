sig Node {
	adj : set Node
}
pred inv8 {
all n: Node | n.adj.adj in n.adj
}

pred inv8c {
	adj = ^adj
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000260 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
pred cap000260c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000260 { cap000260 iff cap000260c }
check CapBenchEquivalent_cap000260 for 4
