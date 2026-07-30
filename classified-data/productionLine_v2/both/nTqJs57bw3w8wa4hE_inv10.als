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
pred inv10 {
all disj w1, w2: Workstation, c1, c2: Component | c2 in c1.^(parts) => w2 in c2.workstation && w1 in c1.workstation && w1 in w2.^(succ) && w1 != w2
}

pred inv10c {
	all c : Component, p : c.parts | p.workstation in ^succ.(c.workstation)
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 

