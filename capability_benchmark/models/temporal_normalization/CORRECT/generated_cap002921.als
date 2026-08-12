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

pred cap002921 { not eventually ((inv1 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002921c { always (not (inv1 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002921 { cap002921 iff cap002921c }
check CapBenchEquivalent_cap002921 for 4
