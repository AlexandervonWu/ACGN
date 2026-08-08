module alloy4fun_augmented_productionLineNew_inv6
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

pred inv6_oracle[] {
no c : Component | c in c.^parts
}

pred inv6_correct_0[] {
all c:Component| c not in c.^parts
}

pred inv6_correct_1[] {
all c: Component | not c in c.^parts
}

pred inv6_correct_2[] {
all c1, c2: Component | c2 in c1.^parts implies c2 != c1
}

pred inv6_correct_3[] {
all x1 : Component | x1 not in x1.^parts
}

pred inv6_correct_4[] {
all x: Component | x not in x.^parts
}

pred inv6_correct_5[] {
all x,y : Component | x in y.^parts implies x!=y
}

pred inv6_correct_6[] {
all c : Component | c not in ^parts.c
}

pred inv6_correct_7[] {
all p : Product | p in Component implies p not in p.^parts
}

pred inv6_correct_8[] {
all c : Component | all p : Product | c in p.^parts implies c !=p
}

pred inv6_correct_9[] {
all c:Component, p:Product | not c in c.^parts
}

pred inv6_correct_10[] {
all c:Product | c in Component implies not c in c.^parts
}

pred inv6_correct_11[] {
no c : Component | c in c.^(~parts)
}

