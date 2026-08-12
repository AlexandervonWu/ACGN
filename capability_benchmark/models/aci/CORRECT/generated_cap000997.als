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

pred cap000997 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000997c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000997 { cap000997 iff cap000997c }
check CapBenchEquivalent_cap000997 for 4
