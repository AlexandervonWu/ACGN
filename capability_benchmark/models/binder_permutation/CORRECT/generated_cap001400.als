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

pred cap001400 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001400c { all a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001400 { cap001400 iff cap001400c }
check CapBenchEquivalent_cap001400 for 4
