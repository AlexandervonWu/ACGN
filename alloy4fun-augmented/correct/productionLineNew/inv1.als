module alloy4fun_augmented_productionLineNew_inv1
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

pred inv1_oracle[] {
Worker = Human + Robot
}

pred inv1_correct_0[] {
all w : Worker | w in Human+Robot
}

pred inv1_correct_1[] {
all x: Worker| x in Human or x in Robot
}

pred inv1_correct_2[] {
all w:Worker | (w in Human) or (w in Robot)
}

pred inv1_correct_3[] {
no Human&Robot
Worker = Human + Robot
}

pred inv1_correct_4[] {
all x : Worker | x in Robot+Human and x not in Robot&Human
}

pred inv1_correct_5[] {
all w : Worker | (w in Human or w in Robot) and (w not in Human or w not in Robot)
}

pred inv1_correct_6[] {
all h : Worker | h in (Human + Robot)
}

pred inv1_correct_7[] {
all x : Worker - Human - Robot | #x = 0
}

pred inv1_correct_8[] {
all w : Worker | w in Robot or w in Human
}

pred inv1_correct_9[] {
Worker in Human+Robot
}

pred inv1_correct_10[] {
no Worker - (Robot + Human)
Worker = Robot + Human
}

pred inv1_correct_11[] {
all w : Worker | w in Human or w in Robot and (w not in Human or w not in Robot)
}

pred inv1_correct_12[] {
Human & Robot = none
Worker = Human + Robot
}

pred inv1_correct_13[] {
no Worker - (Robot + Human)
Worker = Robot + Human
all x : Worker | x in Human or x in Robot
}

pred inv1_correct_14[] {
Worker - Human = Robot
Worker - Robot = Human
}

pred inv1_correct_15[] {
all w : Worker | w in Human iff w !in Robot
}

pred inv1_correct_16[] {
all p: Worker | p in Human or p in Robot
}

pred inv1_correct_17[] {
all x : Worker | x in Human+Robot
}

pred inv1_correct_18[] {
all x : Worker | (x in Human or x in Robot) and (x not in Human or x not in Robot)
}

pred inv1_correct_19[] {
all x : Worker | x in ((Robot + Human) - (Robot&Human))
}

pred inv1_correct_20[] {
all u : Worker | u in Human or u in Robot
}

pred inv1_correct_21[] {
all x : Worker | x in Human-Robot || x in Robot-Human
}

pred inv1_correct_22[] {
no (Worker-Human-Robot)
}

pred inv1_correct_23[] {
Worker = Robot + Human
}

pred inv1_correct_24[] {
all a:Worker | a in Human or a in Robot
}

pred inv1_correct_25[] {
all x: Worker| x in Robot or x in Human
}

pred inv1_correct_26[] {
no Worker - (Robot + Human)
Worker = Robot + Human


no Robot & Human
}

pred inv1_correct_27[] {
no Worker - Robot - Human
}

pred inv1_correct_28[] {
all x : Worker | x in Robot + Human
}

pred inv1_correct_29[] {
no Worker - (Robot + Human)
}

