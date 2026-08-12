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
all b : begin | all e : end | Workstation-b in b.^(succ) and no e.^(succ)
all w : Workstation | lone w.succ
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

pred cap003080 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and no CapBenchA) or some CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap003080c { all renamed: CapBenchA | (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv9 and ((some CapBenchA and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003080 { cap003080 iff cap003080c }
check CapBenchEquivalent_cap003080 for 4
