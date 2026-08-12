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

pred cap001593 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
pred cap001593c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001593 { cap001593 iff cap001593c }
check CapBenchEquivalent_cap001593 for 4
