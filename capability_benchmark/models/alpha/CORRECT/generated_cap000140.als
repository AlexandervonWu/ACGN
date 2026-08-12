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

pred cap000140 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
pred cap000140c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000140 { cap000140 iff cap000140c }
check CapBenchEquivalent_cap000140 for 4
