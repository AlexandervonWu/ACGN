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
all p: Product - Material | some p.parts
all m: Material | no m.parts
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

pred cap002785 { not once ((inv4 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap002785c { historically (not (inv4 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002785 { cap002785 iff cap002785c }
check CapBenchEquivalent_cap002785 for 4
