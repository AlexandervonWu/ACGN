module alloy4fun_augmented_productionLine_v2_inv7
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

pred inv7_oracle[] {
all c : Component | some c.parts & Dangerous implies c in Dangerous
}

pred inv7_correct_0[] {
all c : Component | c in parts.Dangerous implies c in Dangerous
}

pred inv7_correct_1[] {
all c : Component | all p : Product | p in Dangerous and p in c.parts implies c in Dangerous
}

pred inv7_correct_2[] {
all c : Component, p:Product | p in c.parts and p in Dangerous implies c in Dangerous
}

pred inv7_correct_3[] {
all d : Dangerous | all c : Component | c->d in parts implies c in Dangerous
}

pred inv7_correct_4[] {
all c : Component | some (Dangerous & (c . parts)) => c in Dangerous
}

pred inv7_correct_5[] {
all c: Component, p : c.parts | some p & Dangerous implies c in Dangerous
}

pred inv7_correct_6[] {
all c: Component, d: Dangerous | d in c.parts implies c in Dangerous
}

pred inv7_correct_7[] {
all c : Component | all p : Product | (c->p in parts and p in Dangerous) implies c in Dangerous
}

pred inv7_correct_8[] {
all c: Component, p: Product |  p in Dangerous and p in c.parts implies c in Dangerous
}

pred inv7_correct_9[] {
all c,d : univ | c in Component and d in Dangerous and c->d in parts implies c in Dangerous
}

pred inv7_correct_10[] {
all com: Component | all d: Dangerous | d in com.parts implies com in Dangerous
}

pred inv7_correct_11[] {
all c: Component, p : c.parts | p in Dangerous implies c in Dangerous
}

pred inv7_correct_12[] {
all x : Component | no x.parts & Dangerous or x in Dangerous
}

pred inv7_correct_13[] {
all c : Component | all d : Dangerous | d in c.parts implies c in Dangerous
}

pred inv7_correct_14[] {
all c:Component, p:Product | c->p in parts and p in Dangerous implies c in Dangerous
}

pred inv7_correct_15[] {
all c:Component | no c.parts & Dangerous or one c & Dangerous
}

pred inv7_correct_16[] {
all p: Product | p in Component and some(p.parts & Dangerous) implies p in Dangerous
}

pred inv7_correct_17[] {
all x : Component | no x.parts & Dangerous or one x & Dangerous
}

pred inv7_correct_18[] {
all c:Component | all d:Dangerous | c->d in parts implies c in Dangerous
}

pred inv7_correct_19[] {
all c: Component | all p : c.parts | p in Dangerous implies c in Dangerous
}

