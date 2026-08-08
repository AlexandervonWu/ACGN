module alloy4fun_augmented_productionLine_v2_inv10
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

pred inv10_oracle[] {
all c : Component, p : c.parts | p.workstation in ^succ.(c.workstation)
}

pred inv10_correct_0[] {
all c : Component | c.parts.workstation in (^succ).(c.workstation)
}

pred inv10_correct_1[] {
all c : Component | (c.parts & Component).workstation in c.workstation.^(~succ)
}

