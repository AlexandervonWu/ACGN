sig Workstation {
	workers : set Worker,
	succ : set Workstation
}
one sig begin, end in Workstation {}

sig Worker {}
sig Human, Robot extends Worker {}

abstract sig Product {
	parts : set Product	
}

sig Material extends Product {}

sig Component extends Product {
	workstation : set Workstation
}

sig Dangerous in Product {}
pred inv4 {
all x: Component | some x.parts
all x : Material | no x.parts
}

pred inv4c {
	all c : Component | some c.parts
	all m : Material | no m.parts	

}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004836 { not ((inv4 and ((some CapBenchA and no CapBenchA) or some capBenchS)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004836c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some CapBenchA and no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004836 { cap004836 iff cap004836c }
check CapBenchEquivalent_cap004836 for 4
