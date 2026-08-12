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

pred cap000518 { ((inv3 and ((no CapBenchA and no CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) and ((some capBenchS or some capBenchS) or some capBenchS)) }
pred cap000518c { (((some capBenchS or some capBenchS) or some capBenchS) and (inv3 and ((no CapBenchA and no CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap000518 { cap000518 iff cap000518c }
check CapBenchEquivalent_cap000518 for 4
