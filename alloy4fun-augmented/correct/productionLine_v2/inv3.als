module alloy4fun_augmented_productionLine_v2_inv3
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
all c : Component | one ws : Workstation | c->ws in workstation
}

pred inv3_correct_1[] {
workstation in Component -> one Workstation
}

pred inv3_correct_2[] {
all c : Component | one wks: Workstation | c->wks in workstation
}

pred inv3_correct_3[] {
all c : Component | one w : Workstation | w in c.workstation
}

pred inv3_correct_4[] {
all com: Component | one ws: Workstation | ws in com.workstation
}

pred inv3_correct_5[] {
all c: Component | one w: Workstation | c->w in workstation
}

pred inv3_correct_6[] {
all c:Component | one ws:Workstation | ws in c.workstation
}

pred inv3_correct_7[] {
all c : Component | one (c.workstation & Workstation)
}

pred inv3_correct_8[] {
all co: Component | one co.workstation
}

pred inv3_correct_9[] {
all c: Component | one s: Workstation | c->s in workstation
}

pred inv3_correct_10[] {
all c : Component | some w1 : Workstation | c->w1 in workstation and all w2 : Workstation | c->w2 in workstation implies w1 = w2
}

pred inv3_correct_11[] {
all c : Component | one w : Workstation | c.workstation = w
}

pred inv3_correct_12[] {
all c : Component | one wb : Workstation | c->wb in workstation
}

pred inv3_correct_13[] {
all com: Component | one com.workstation
}

pred inv3_correct_14[] {
(iden :> Component in workstation.~workstation) and  (~workstation.workstation in iden)
}

pred inv3_correct_15[] {
all a:Component | some b:Workstation | a->b in workstation
all a1,a2:Workstation | (some b:Component | b->a1 in workstation and b->a2 in workstation) implies a1 = a2
}

pred inv3_correct_16[] {
all x : Component | some y : Workstation | one x.workstation & y + x.workstation & (Workstation-y)
}

pred inv3_correct_17[] {
all comp: Component | one w: Workstation | w in comp.workstation
}

pred inv3_correct_18[] {
all c:Component | one wt:Workstation | wt in c.workstation
}

pred inv3_correct_19[] {
all c : Component | one w : Workstation | c in workstation.w
}

pred inv3_correct_20[] {
all x : Component | some y : Workstation | one x.workstation & y and no x.workstation & (Workstation-y)
}

pred inv3_correct_21[] {
all c : Component | one wb : Workstation | one (c.workstation & wb)
}

