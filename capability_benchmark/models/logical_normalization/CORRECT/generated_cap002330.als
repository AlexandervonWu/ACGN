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

pred cap002330 { not not ((inv7 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap002330c { (inv7 and ((no CapBenchA and some CapBenchB) and some capBenchS)) }
assert CapBenchEquivalent_cap002330 { cap002330 iff cap002330c }
check CapBenchEquivalent_cap002330 for 4
