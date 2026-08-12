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

pred cap002068 { ((inv3 and ((some capBenchR and some CapBenchA) or some CapBenchB)) implies ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap002068c { ((not (inv3 and ((some capBenchR and some CapBenchA) or some CapBenchB))) or ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
assert CapBenchEquivalent_cap002068 { cap002068 iff cap002068c }
check CapBenchEquivalent_cap002068 for 4
