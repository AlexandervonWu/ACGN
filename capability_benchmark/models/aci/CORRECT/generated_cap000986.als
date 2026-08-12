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
  all c:Component, p:c.position | some r:Robot | r.position = p
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

pred cap000986 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or no CapBenchA) and no CapBenchA) and ((some CapBenchB or some CapBenchA) or some capBenchS)) }
pred cap000986c { (((some CapBenchB or some CapBenchA) or some capBenchS) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or no CapBenchA) and no CapBenchA)) }
assert CapBenchEquivalent_cap000986 { cap000986 iff cap000986c }
check CapBenchEquivalent_cap000986 for 4
