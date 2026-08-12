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

pred cap002893 { not once ((inv7 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002893c { historically (not (inv7 and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002893 { cap002893 iff cap002893c }
check CapBenchEquivalent_cap002893 for 4
