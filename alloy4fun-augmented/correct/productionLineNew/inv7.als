module alloy4fun_augmented_productionLineNew_inv7
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
all c : Component, p : c.parts | p in Dangerous implies c in Dangerous
}

pred inv7_correct_1[] {
all c : Component | all p : c.parts | (p in Dangerous) implies (c in Dangerous )
}

pred inv7_correct_2[] {
all c : Component | (some d : Dangerous | d in c.parts) implies c in Dangerous
}

pred inv7_correct_3[] {
all c:Component | all p:Product | (p in Dangerous and p in c.parts) implies c in Dangerous
}

pred inv7_correct_4[] {
all c : Component, d : Dangerous | d in c.parts implies c in Dangerous
}

pred inv7_correct_5[] {
all c: Component| all x: c.parts| x in Dangerous implies c in Dangerous
}

pred inv7_correct_6[] {
all c : Component | c in parts.Dangerous => c in Dangerous
}

pred inv7_correct_7[] {
all c : Component | (c.parts & Dangerous != none) => c in Dangerous
}

pred inv7_correct_8[] {
all c: Component| all d: c.parts| d in Dangerous => c in Dangerous
}

pred inv7_correct_9[] {
all x: Component, y: x.parts | y in Dangerous implies x in Dangerous
}

pred inv7_correct_10[] {
all c:Component  | all a:c.parts| a in Dangerous implies c in Dangerous
}

pred inv7_correct_11[] {
all p:Product, c:Component | p in c.parts and p in Dangerous implies c in Dangerous
}

