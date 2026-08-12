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

pred cap002409 { not ((inv3 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) }
pred cap002409c { ((not (inv3 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002409 { cap002409 iff cap002409c }
check CapBenchEquivalent_cap002409 for 4
