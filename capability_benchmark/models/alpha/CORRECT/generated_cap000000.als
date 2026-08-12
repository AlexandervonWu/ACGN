open util/ordering[Position]

sig Position {}

sig Product {}

sig Component extends Product {
    parts : set Product,
    position : one Position
}
sig Resource extends Product {}

sig Robot {
        position : one Position
}
pred inv3 {
  all c:Component, p:c.position | some r:Robot | r.position = p
}

pred inv3c { 
	all c : Component | some position.(c.position) & Robot
}


check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000000 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
pred cap000000c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000000 { cap000000 iff cap000000c }
check CapBenchEquivalent_cap000000 for 4
