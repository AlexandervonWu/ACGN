module alloy4fun_augmented_productionLine_v2_inv4
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
(all c : Component | some p : Product | c->p in parts)
and
(all m : Material | no p : Product | m->p in parts)
}

pred inv4_correct_1[] {
all product: Component | not no product.parts
all mat: Material | no mat.parts
}

pred inv4_correct_2[] {
all p: Product | no p.parts implies p in Material
all p: Product | some p.parts implies p in Component
}

pred inv4_correct_3[] {
all x:Component | some x.parts
all x:Material | no x.parts
}

pred inv4_correct_4[] {
(all c : Component | some p : Product | p in c.parts) and (all m : Material | no p : Product | p in m.parts)
}

pred inv4_correct_5[] {
all com: Component | some p: Product | p in com.parts
all m: Material | no p: Product | p in m.parts
}

pred inv4_correct_6[] {
all c : Component | some c.parts
all c : Material | no c.parts
}

pred inv4_correct_7[] {
no Material.parts
all c : Component | some c.parts
}

pred inv4_correct_8[] {
parts in Component -> some Product
}

pred inv4_correct_9[] {
all c: Component | some c.parts
all m:Material | m.parts = none
}

pred inv4_correct_10[] {
all c:Component | some p:Product | c->p in parts
all m:Material, p:Product | m->p not in parts
}

pred inv4_correct_11[] {
all p: Component| some x: Product| p->x in parts
all m: Material| no p: Product| m->p in parts
}

pred inv4_correct_12[] {
parts in Component -> some Product
no Material.parts
}

pred inv4_correct_13[] {
(all c : Component | some p : Product | p in c.parts) and (all m : Material | no p : Product | m->p in parts)
}

pred inv4_correct_14[] {
all c : Component | some c.parts
no Material.parts
}

pred inv4_correct_15[] {
not some c:Component | no c.parts
not some m:Material | some m.parts
}

pred inv4_correct_16[] {
all c: Component | c.parts != none
all m: Material | m.parts = none
}

pred inv4_correct_17[] {
Component in parts.Product and Material.parts = none
}

pred inv4_correct_18[] {
parts.Product = Component
}

pred inv4_correct_19[] {
all m : Material | no m.parts
all c : Component | some c.parts
}

pred inv4_correct_20[] {
all c : Component | some p : Product | c->p in parts
all m,p : univ | m in Material and p in Product implies not m->p in parts
}

pred inv4_correct_21[] {
(all c:Component | some p:Product | c->p in parts) and (all m:Material | all p:Product | m->p not in parts)
}

pred inv4_correct_22[] {
all c: Component | some c.parts
all m: Material | not some m.parts
}

pred inv4_correct_23[] {
Component = parts.Product
}

pred inv4_correct_24[] {
all c : Component | c in Product.~parts

all m : Material | m not in Product.~parts
}

pred inv4_correct_25[] {
all p : Product | p.parts != none <=> p in Component
}

pred inv4_correct_26[] {
all product: Component | not no product.parts
all product: Product | product not in Material implies some product.parts
all mat: Material | no mat.parts
}

pred inv4_correct_27[] {
(all c: Component | some p: Product | c in parts.p)
and
(all m: Material | no p: Product | m->p in parts)
}

pred inv4_correct_28[] {
all c : Component | c in Product.~parts
no Material & Product.~parts
}

pred inv4_correct_29[] {
(Component <: parts) in Component set -> some Product
no (Material <: parts)
}

pred inv4_correct_30[] {
all c : Component | some p : Product | p in c.parts
all m : Material | all p : Product | p not in m.parts
}

pred inv4_correct_31[] {
all c : Component | some c . parts
Material . parts = none
}

pred inv4_correct_32[] {
all p:Product | p in Component implies some(p.parts)
all p:Product | p in Material implies no(p.parts)
}

pred inv4_correct_33[] {
all p:Product | (no p.parts => p in Material) and (some p.parts => p in Component)
}

pred inv4_correct_34[] {
all c: Component | c.parts != none
all m: Material| no m.parts
}

pred inv4_correct_35[] {
all c : Component | some c.parts
iden not in parts
no Material.parts
}

pred inv4_correct_36[] {
all p: Product | p.parts = none implies p in Material else p in Component
}

pred inv4_correct_37[] {
all c : Component | some p : Product | p in c.parts
all m : Material, p : Product | p not in m.parts
}

pred inv4_correct_38[] {
all a:Component | some b:Product | a->b in parts
all a:Product,b:Product | a->b in parts implies a in Component
}

pred inv4_correct_39[] {
all p: Product | (p in Component implies some p.parts) and (p in Material implies no p.parts)
}

pred inv4_correct_40[] {
(all c: Component | some p: Product | p in c.parts) and
(all m: Material | no prod: Product | prod in m.parts)
}

pred inv4_correct_41[] {
(iden :> Component in parts.~parts) and (no iden :> Material & parts.~parts)
}

pred inv4_correct_42[] {
all com: Component | some com.parts
all mat: Material | no mat.parts
}

pred inv4_correct_43[] {
all product: Product | product not in Material implies some product.parts
all mat: Material | no mat.parts
}

pred inv4_correct_44[] {
all m : Material | no m.parts
Component in parts.Product
}

pred inv4_correct_45[] {
all c: Component | some c.parts
all mat: Material | no mat.parts
}

