sig Node {
	adj : set Node
}
pred inv8 {
all a,b,c : Node | c in b.adj and b in a.adj implies c in a.adj
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

pred cap000380 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap000380c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000380 { cap000380 iff cap000380c }
check CapBenchEquivalent_cap000380 for 4
