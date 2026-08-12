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

pred cap003331 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and some capBenchS)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003331c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003331 { cap003331 iff cap003331c }
check CapBenchEquivalent_cap003331 for 4
