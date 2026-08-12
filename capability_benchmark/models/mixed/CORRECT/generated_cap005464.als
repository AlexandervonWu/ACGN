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

pred cap005464 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap005464c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv3 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005464 { cap005464 iff cap005464c }
check CapBenchEquivalent_cap005464 for 4
