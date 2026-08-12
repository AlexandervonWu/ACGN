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

pred cap002299 { no x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
pred cap002299c { all x: CapBenchA | not (x->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap002299 { cap002299 iff cap002299c }
check CapBenchEquivalent_cap002299 for 4
