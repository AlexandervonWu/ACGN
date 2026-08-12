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

pred cap003290 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003290c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap003290 { cap003290 iff cap003290c }
check CapBenchEquivalent_cap003290 for 4
