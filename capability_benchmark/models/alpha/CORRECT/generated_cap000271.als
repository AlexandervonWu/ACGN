sig Node {
	adj : set Node
}
pred inv7 {
all n:Node | Node in n.*adj
}

pred inv7c {
	all n:Node | Node = n.*adj
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 





sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000271 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap000271c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000271 { cap000271 iff cap000271c }
check CapBenchEquivalent_cap000271 for 4
