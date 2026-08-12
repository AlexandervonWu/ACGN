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

pred cap003484 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchA) or no CapBenchA)) }
pred cap003484c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003484 { cap003484 iff cap003484c }
check CapBenchEquivalent_cap003484 for 4
