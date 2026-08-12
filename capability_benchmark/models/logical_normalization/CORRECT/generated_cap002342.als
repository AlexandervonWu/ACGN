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

pred cap002342 { not not ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
pred cap002342c { (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) }
assert CapBenchEquivalent_cap002342 { cap002342 iff cap002342c }
check CapBenchEquivalent_cap002342 for 4
