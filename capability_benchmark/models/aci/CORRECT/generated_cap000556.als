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

pred cap000556 { (inv7 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap000556c { ((inv7 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and (inv7 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000556 { cap000556 iff cap000556c }
check CapBenchEquivalent_cap000556 for 4
