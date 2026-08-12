sig Node {
	adj : set Node
}
pred inv5 {
all n: Node | not n->n in adj
}

pred inv5c {
	no adj & iden
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000769 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv5 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
pred cap000769c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv5 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000769 { cap000769 iff cap000769c }
check CapBenchEquivalent_cap000769 for 4
