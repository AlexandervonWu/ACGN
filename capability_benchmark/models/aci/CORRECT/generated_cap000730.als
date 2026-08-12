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

pred cap000730 { (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) }
pred cap000730c { ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap000730 { cap000730 iff cap000730c }
check CapBenchEquivalent_cap000730 for 4
