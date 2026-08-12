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

pred cap000665 { (inv3 and ((some capBenchS or some capBenchR) or no CapBenchA)) }
pred cap000665c { ((inv3 and ((some capBenchS or some capBenchR) or no CapBenchA)) or (inv3 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap000665 { cap000665 iff cap000665c }
check CapBenchEquivalent_cap000665 for 4
