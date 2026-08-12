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

pred cap002199 { not ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap002199c { ((not (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap002199 { cap002199 iff cap002199c }
check CapBenchEquivalent_cap002199 for 4
