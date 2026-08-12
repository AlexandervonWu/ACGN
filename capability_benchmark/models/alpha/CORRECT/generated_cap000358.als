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

pred cap000358 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
pred cap000358c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap000358 { cap000358 iff cap000358c }
check CapBenchEquivalent_cap000358 for 4
