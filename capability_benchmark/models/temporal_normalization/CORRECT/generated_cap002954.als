sig Node {
	adj : set Node
}
pred inv3 {
all n:Node | n not in n.^adj
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

pred cap002954 { not (((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) until (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
pred cap002954c { ((not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) releases (not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
assert CapBenchEquivalent_cap002954 { cap002954 iff cap002954c }
check CapBenchEquivalent_cap002954 for 4
