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

pred cap004520 { not ((inv3 and ((some capBenchR and no CapBenchA) or some CapBenchA)) and ((some CapBenchB or some CapBenchA) or no CapBenchB)) }
pred cap004520c { ((not ((some CapBenchB or some CapBenchA) or no CapBenchB)) or (not (inv3 and ((some capBenchR and no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004520 { cap004520 iff cap004520c }
check CapBenchEquivalent_cap004520 for 4
