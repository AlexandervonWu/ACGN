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

pred cap000498 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000498c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000498 { cap000498 iff cap000498c }
check CapBenchEquivalent_cap000498 for 4
