module alloy4fun_augmented_productionLineNew_inv3
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

pred inv3_oracle[] {
all c : Component | one c.workstation
}

pred inv3_correct_0[] {
all c: Component | one ws: Workstation | ws in c.workstation
}

pred inv3_correct_1[] {
all c :Component | #c.workstation=1
}

pred inv3_correct_2[] {
all c : Component | one w : Workstation | w in c.workstation
}

pred inv3_correct_3[] {
all x : Component | one y : Workstation | y in x.workstation
}

pred inv3_correct_4[] {
all c:Component | one wk:Workstation | wk in c.workstation
}

pred inv3_correct_5[] {
workstation in Component set -> one Workstation
}

pred inv3_correct_6[] {
all x:Component | one w:Workstation | w in x.workstation
}

pred inv3_correct_7[] {
all x : Component | one x.workstation
}

pred inv3_correct_8[] {
all x: Component | some y : Workstation | y in x.workstation
all x: Component | all y, z : Workstation | x in workstation.y and x in workstation.z implies y = z
}

pred inv3_correct_9[] {
all c : Component | one ws : Workstation | one c.workstation & ws
}

pred inv3_correct_10[] {
all w : Component | one s : Workstation | s in w.workstation
}

pred inv3_correct_11[] {
all c: Component |one wo:Workstation| wo in  c.workstation
}

pred inv3_correct_12[] {
all c : Component | one w : Workstation | c->w in workstation
}

pred inv3_correct_13[] {
all c:Component| one s:Workstation| c->s in workstation
}

pred inv3_correct_14[] {
all c: Component | one ws:Workstation | c -> ws in workstation
}

pred inv3_correct_15[] {
all c: Component | one ws: Workstation | c in ws.~workstation
}

