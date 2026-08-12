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
all w:Worker | w in Human or w in Robot
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

pred cap004605 { not ((inv1 and ((some CapBenchB or some capBenchS) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) }
pred cap004605c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) or (not (inv1 and ((some CapBenchB or some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004605 { cap004605 iff cap004605c }
check CapBenchEquivalent_cap004605 for 4
