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

pred cap001416 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001416c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001416 { cap001416 iff cap001416c }
check CapBenchEquivalent_cap001416 for 4
