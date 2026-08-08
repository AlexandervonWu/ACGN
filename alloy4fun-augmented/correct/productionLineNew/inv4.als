module alloy4fun_augmented_productionLineNew_inv4
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

pred inv4_oracle[] {
all c : Component | some c.parts
	all m : Material | no m.parts
}

pred inv4_correct_0[] {
all c : Component | c.parts != none
all m : Material | m.parts = none
}

pred inv4_correct_1[] {
all c: Component | #c.parts>0
(all m: Material | no m.parts)
}

pred inv4_correct_2[] {
all c : Component - Material | some c.parts
all m : Material | no m.parts
}

pred inv4_correct_3[] {
all c : Component | #c.parts > 0
all m : Material | #m.parts = 0
}

pred inv4_correct_4[] {
all c:Component | some c.parts
all c:Material |no c.parts
}

pred inv4_correct_5[] {
all c: Component | some p : Product | p in c.parts
all c: Material | no c.parts
}

pred inv4_correct_6[] {
all p : Product | p in Material <=> no p.parts
all p : Product | p in Component <=> some p.parts
}

pred inv4_correct_7[] {
all x:Component | #(x.parts)>0
all x:Material | #(x.parts)=0
}

pred inv4_correct_8[] {
(Component <: parts) in Component set -> some Product
no (Material <: parts)
}

pred inv4_correct_9[] {
all p : Product | (p in Component && some p.parts) || (p in Material && no p.parts)
}

pred inv4_correct_10[] {
all p: Product - Material | some p.parts
all m: Material | no m.parts
}

pred inv4_correct_11[] {
(all c : Component | some c.parts) and (no Material.parts)
}

pred inv4_correct_12[] {
all p : Product | p in Material implies no p.parts
all p : Product | p in Component implies some p.parts
}

pred inv4_correct_13[] {
all x:Component | some x.parts
all x:Material | no x.parts
}

pred inv4_correct_14[] {
all c : Component | (some c.parts)
all m : Material | no m.parts

no Material.parts
}

pred inv4_correct_15[] {
all c : Component | some c.parts
all m : Material | no m.parts

parts.Product = Component
}

pred inv4_correct_16[] {
parts.Product = Component
}

pred inv4_correct_17[] {
(all c : Component | some p : Product | c in parts.p) and (all m : Material | no p : Product | m in parts.p)
}

pred inv4_correct_18[] {
(all m: Material | no m.parts) && (all c: Component | some c.parts)
}

pred inv4_correct_19[] {
all p : Product | (p in Component implies some p.parts) and (p in Material implies no p.parts)
}

pred inv4_correct_20[] {
all m : Material | #m.parts=0
all c : Component | #c.parts>0
}

pred inv4_correct_21[] {
all p : Product | p in Component implies some p.parts
all p : Product | p in Material implies no p.parts
}

pred inv4_correct_22[] {
(all c:Component | some p:Product | p in c.parts)
and
(all m:Material | no p:Product | p in m.parts)
}

pred inv4_correct_23[] {
(all c:Component | some p:Product | p in c.parts)
and
(all m:Material | all p:Product | p not in m.parts)
}

pred inv4_correct_24[] {
all c: Component | #c.parts>0
all c :Material | no c.parts
}

pred inv4_correct_25[] {
(all c : Component | some p : Product | c->p in parts)
and
(all m : Material | no p : Product | m->p in parts)
}

pred inv4_correct_26[] {
all x: Product | (x in Component && some x.parts) || (x in Material && no x.parts)
}

pred inv4_correct_27[] {
all x: Component | some x.parts
all y: Material | no y.parts
}

pred inv4_correct_28[] {
all c: Component | some p: Product| p in c.parts
all c: Material | all p: Product| p not in c.parts
}

pred inv4_correct_29[] {
all c:Component | some p:Product | p in c.parts
all m:Material | no m.parts
}

pred inv4_correct_30[] {
all p: Product |
(p in Component) => (#p.parts > 0)
all p: Material | #p.parts = 0
}

pred inv4_correct_31[] {
(all c: Component| some c.parts) && (all m: Material| #m.parts=0)
}

pred inv4_correct_32[] {
all x: Product |  x in Component implies some x.parts
all x: Product |  x in Material implies no x.parts
}

pred inv4_correct_33[] {
(all c : Component | some p : Product | c in parts.p) and (all m : Material | no p : Product | m->p in parts)
}

