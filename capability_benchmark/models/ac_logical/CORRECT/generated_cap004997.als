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

pred cap004997 { not ((inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) }
pred cap004997c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) or (not (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004997 { cap004997 iff cap004997c }
check CapBenchEquivalent_cap004997 for 4
