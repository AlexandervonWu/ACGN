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

pred cap000274 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap000274c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000274 { cap000274 iff cap000274c }
check CapBenchEquivalent_cap000274 for 4
