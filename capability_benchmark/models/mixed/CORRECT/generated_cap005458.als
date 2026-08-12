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

pred cap005458 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
pred cap005458c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) or (not (inv9 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005458 { cap005458 iff cap005458c }
check CapBenchEquivalent_cap005458 for 4
