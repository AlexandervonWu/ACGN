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

pred cap002529 { not (((inv7 and ((some capBenchS or no CapBenchB) or some CapBenchA))) since (((no CapBenchA and some CapBenchB) and no CapBenchB))) }
pred cap002529c { ((not (inv7 and ((some capBenchS or no CapBenchB) or some CapBenchA))) triggered (not ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002529 { cap002529 iff cap002529c }
check CapBenchEquivalent_cap002529 for 4
