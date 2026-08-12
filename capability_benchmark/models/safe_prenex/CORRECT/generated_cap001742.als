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

pred cap001742 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap001742c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001742 { cap001742 iff cap001742c }
check CapBenchEquivalent_cap001742 for 4
