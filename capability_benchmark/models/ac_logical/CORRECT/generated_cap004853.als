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
pred inv1 {
all w : Worker | w in Human + Robot
}

pred inv1c {
	Worker = Human + Robot	
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004853 { not ((inv1 and ((some CapBenchB or some capBenchR) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) }
pred cap004853c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) or (not (inv1 and ((some CapBenchB or some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap004853 { cap004853 iff cap004853c }
check CapBenchEquivalent_cap004853 for 4
