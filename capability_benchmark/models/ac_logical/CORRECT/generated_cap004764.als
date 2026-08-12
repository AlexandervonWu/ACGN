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

pred cap004764 { not ((inv3 and ((some CapBenchA and some CapBenchB) or some capBenchR)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004764c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchA and some CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004764 { cap004764 iff cap004764c }
check CapBenchEquivalent_cap004764 for 4
