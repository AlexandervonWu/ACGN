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

pred cap000737 { (inv7 and ((some capBenchS or some capBenchS) or no CapBenchB)) }
pred cap000737c { ((inv7 and ((some capBenchS or some capBenchS) or no CapBenchB)) or (inv7 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap000737 { cap000737 iff cap000737c }
check CapBenchEquivalent_cap000737 for 4
