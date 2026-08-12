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

pred cap002033 { ((inv7 and ((some CapBenchB or some capBenchR) or some CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) }
pred cap002033c { (((not (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) or (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap002033 { cap002033 iff cap002033c }
check CapBenchEquivalent_cap002033 for 4
