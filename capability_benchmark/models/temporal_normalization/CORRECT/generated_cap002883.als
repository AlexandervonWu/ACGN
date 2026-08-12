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
all c : Component | some c.parts
iden not in parts
no Material.parts
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

pred cap002883 { not (((inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) since (((some capBenchR and some capBenchS) or some CapBenchA))) }
pred cap002883c { ((not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) triggered (not ((some capBenchR and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap002883 { cap002883 iff cap002883c }
check CapBenchEquivalent_cap002883 for 4
