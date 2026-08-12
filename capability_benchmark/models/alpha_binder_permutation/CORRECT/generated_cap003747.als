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

pred cap003747 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap003747c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap003747 { cap003747 iff cap003747c }
check CapBenchEquivalent_cap003747 for 4
