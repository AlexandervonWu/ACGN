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

pred cap000567 { ((inv7 and ((no CapBenchB or some CapBenchA) and some CapBenchB)) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000567c { (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) or (inv7 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000567 { cap000567 iff cap000567c }
check CapBenchEquivalent_cap000567 for 4
