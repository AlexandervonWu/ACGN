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

pred cap003132 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap003132c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR) and renamed->renamed in capBenchR and (inv9 and ((some capBenchR and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003132 { cap003132 iff cap003132c }
check CapBenchEquivalent_cap003132 for 4
