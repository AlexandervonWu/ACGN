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

pred cap003633 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
pred cap003633c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003633 { cap003633 iff cap003633c }
check CapBenchEquivalent_cap003633 for 4
