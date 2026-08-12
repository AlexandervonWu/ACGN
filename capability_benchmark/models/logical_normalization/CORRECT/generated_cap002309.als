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
pred inv5 {
all w:Workstation, h:Human, r:Robot | h not in w.workers or r not in w.workers
}

pred inv5c {
	all c : Workstation | no (c.workers & Human) or no (c.workers & Robot)
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002309 { ((inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) iff ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002309c { (((not (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) or ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((not ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap002309 { cap002309 iff cap002309c }
check CapBenchEquivalent_cap002309 for 4
