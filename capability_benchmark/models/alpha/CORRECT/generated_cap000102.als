sig Node {
	adj : set Node
}
pred inv3 {
all n : Node | n not in n.^adj

no (^adj & iden)

iden - ^adj = iden
}

pred inv3c {
	all n : Node | n not in n.^adj
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000102 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
pred cap000102c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap000102 { cap000102 iff cap000102c }
check CapBenchEquivalent_cap000102 for 4
