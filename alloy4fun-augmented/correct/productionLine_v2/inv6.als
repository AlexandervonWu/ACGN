module alloy4fun_augmented_productionLine_v2_inv6
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
all c : Component | c not in c.^parts
}

pred inv6_correct_1[] {
all component: Component | component not in component.^parts
}

pred inv6_correct_2[] {
all c,p : univ | c in Component and p in Product and c->p in parts implies p!=c and p->c not in parts and all p1 : Product | p->p1 in parts implies p1->c not in parts
}

pred inv6_correct_3[] {
all c1:Component | no c1 & c1.^parts
}

pred inv6_correct_4[] {
all c:Component |  no(c & (c.^parts))
}

pred inv6_correct_5[] {
all c: Product | c in Component implies c not in c.^(parts)
}

pred inv6_correct_6[] {
all c : Component | not c in c.^parts
}

pred inv6_correct_7[] {
all com: Component | com not in com.^(parts)
}

pred inv6_correct_8[] {
all x : Component | no x & x.^(parts)
}

pred inv6_correct_9[] {
all c:Component | c->c not in ^parts
}

pred inv6_correct_10[] {
all c: Component, p: Product | no (c & c.^parts)
}

