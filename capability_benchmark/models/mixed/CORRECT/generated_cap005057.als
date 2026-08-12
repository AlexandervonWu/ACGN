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
	all c:Component, p:Position | some(c.position & Robot.position)
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

pred cap005057 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
pred cap005057c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) or (not (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005057 { cap005057 iff cap005057c }
check CapBenchEquivalent_cap005057 for 4
