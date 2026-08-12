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

pred cap000639 { ((inv7 and ((no CapBenchB or some CapBenchB) and no CapBenchA)) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000639c { (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB) or (inv7 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000639 { cap000639 iff cap000639c }
check CapBenchEquivalent_cap000639 for 4
