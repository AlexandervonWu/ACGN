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
all w : Workstation | (no succ.w <=> w in begin) and (no w.succ <=> w in end) and lone w.succ
no (^succ & iden)
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

pred cap002219 { ((inv9 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) iff ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002219c { (((not (inv9 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) or ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((not ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (inv9 and ((no CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap002219 { cap002219 iff cap002219c }
check CapBenchEquivalent_cap002219 for 4
