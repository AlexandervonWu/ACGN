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
pred inv3 {
all x : Component | one y : Workstation | y in x.workstation
}

pred inv3c {
	all c : Component | one c.workstation
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004037 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
pred cap004037c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap004037 { cap004037 iff cap004037c }
check CapBenchEquivalent_cap004037 for 4
