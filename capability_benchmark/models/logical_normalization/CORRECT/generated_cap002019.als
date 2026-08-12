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

pred cap002019 { not ((inv3 and ((no CapBenchB or no CapBenchA) and some CapBenchA)) and ((some CapBenchA and some CapBenchA) or no CapBenchB)) }
pred cap002019c { ((not (inv3 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) or (not ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002019 { cap002019 iff cap002019c }
check CapBenchEquivalent_cap002019 for 4
