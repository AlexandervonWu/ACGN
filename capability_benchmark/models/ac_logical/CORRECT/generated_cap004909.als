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

pred cap004909 { not ((inv7 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) }
pred cap004909c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) or (not (inv7 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004909 { cap004909 iff cap004909c }
check CapBenchEquivalent_cap004909 for 4
