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

pred cap001812 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap001812c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001812 { cap001812 iff cap001812c }
check CapBenchEquivalent_cap001812 for 4
