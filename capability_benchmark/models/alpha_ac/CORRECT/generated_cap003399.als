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

pred cap003399 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap003399c { all renamed: CapBenchA | (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003399 { cap003399 iff cap003399c }
check CapBenchEquivalent_cap003399 for 4
