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

pred cap002952 { not historically ((inv7 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002952c { once (not (inv7 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002952 { cap002952 iff cap002952c }
check CapBenchEquivalent_cap002952 for 4
