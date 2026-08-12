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

pred cap002492 { not not ((inv3 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002492c { (inv3 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002492 { cap002492 iff cap002492c }
check CapBenchEquivalent_cap002492 for 4
