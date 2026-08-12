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

pred cap002630 { not (((inv7 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) until (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
pred cap002630c { ((not (inv7 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap002630 { cap002630 iff cap002630c }
check CapBenchEquivalent_cap002630 for 4
