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
pred inv9 {
all b : begin | all e : end | Workstation-b in b.^(succ) and no e.^(succ)
all w : Workstation | lone w.succ
}

pred inv9c {
	all w : Workstation - end | one w.succ
	no end.succ
	Workstation in begin.*succ
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002373 { not ((inv9 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((no CapBenchA and some capBenchR) and some CapBenchA)) }
pred cap002373c { ((not (inv9 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) or (not ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap002373 { cap002373 iff cap002373c }
check CapBenchEquivalent_cap002373 for 4
