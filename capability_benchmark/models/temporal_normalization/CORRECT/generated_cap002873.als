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

pred cap002873 { not eventually ((inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap002873c { always (not (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap002873 { cap002873 iff cap002873c }
check CapBenchEquivalent_cap002873 for 4
