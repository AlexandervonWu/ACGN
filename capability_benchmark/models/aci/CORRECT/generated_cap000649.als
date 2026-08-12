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

pred cap000649 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
pred cap000649c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000649 { cap000649 iff cap000649c }
check CapBenchEquivalent_cap000649 for 4
