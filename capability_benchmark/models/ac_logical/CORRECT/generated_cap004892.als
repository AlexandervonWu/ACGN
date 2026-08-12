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
pred inv7 {
all c: Component | all x: c.parts | x in Dangerous => c in Dangerous
}

pred inv7c {
	all c : Component | some c.parts & Dangerous implies c in Dangerous
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004892 { not ((inv7 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap004892c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (not (inv7 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004892 { cap004892 iff cap004892c }
check CapBenchEquivalent_cap004892 for 4
