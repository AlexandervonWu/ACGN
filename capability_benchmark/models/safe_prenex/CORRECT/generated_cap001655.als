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

pred cap001655 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap001655c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((no CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001655 { cap001655 iff cap001655c }
check CapBenchEquivalent_cap001655 for 4
