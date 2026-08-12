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
all w : Workstation | w != begin => one succ.w
all w : Workstation | w != end => one w.succ
all w : Workstation | w not in w.^succ
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

pred cap000602 { ((inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((no CapBenchB or no CapBenchA) and some capBenchR) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000602c { (((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB)) and ((no CapBenchB or no CapBenchA) and some capBenchR)) }
assert CapBenchEquivalent_cap000602 { cap000602 iff cap000602c }
check CapBenchEquivalent_cap000602 for 4
