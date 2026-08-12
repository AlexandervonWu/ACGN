sig Node {
	adj : set Node
}
pred inv7 {
all n1,n2:Node | n2 in n1.*adj
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

pred cap002044 { ((inv7 and ((some capBenchR and some capBenchS) or some CapBenchA)) implies ((some CapBenchB or no CapBenchB) or no CapBenchB)) }
pred cap002044c { ((not (inv7 and ((some capBenchR and some capBenchS) or some CapBenchA))) or ((some CapBenchB or no CapBenchB) or no CapBenchB)) }
assert CapBenchEquivalent_cap002044 { cap002044 iff cap002044c }
check CapBenchEquivalent_cap002044 for 4
