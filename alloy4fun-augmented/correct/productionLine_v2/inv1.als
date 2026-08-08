module alloy4fun_augmented_productionLine_v2_inv1
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
all w : Worker | w in Human or w in Robot
}

pred inv1_correct_1[] {
Worker in  Human + Robot
}

pred inv1_correct_2[] {
all w : Worker | w in Human or w in Robot
all w : Worker | w in Human implies w not in Robot
all w : Worker | w in Robot implies w not in Human
}

pred inv1_correct_3[] {
Worker in (Robot+Human)
}

pred inv1_correct_4[] {
all w:Worker | w in Human + Robot
}

pred inv1_correct_5[] {
all w : Worker | w in Human <=> w not in Robot
}

pred inv1_correct_6[] {
Human <: Worker = Worker - (Robot <: Worker)
}

pred inv1_correct_7[] {
all w : Worker | w in Robot or w in Human
}

pred inv1_correct_8[] {
all w : Worker | w in Robot+Human
}

pred inv1_correct_9[] {
all w1: Worker | (w1 in Human or w1 in Robot)
}

pred inv1_correct_10[] {
no Worker-(Human+Robot)
}

pred inv1_correct_11[] {
not some w:Worker | not w in Human + Robot
}

pred inv1_correct_12[] {
no Worker - Human - Robot
}

pred inv1_correct_13[] {
(Human & Worker) = Worker - (Robot & Worker)
}

pred inv1_correct_14[] {
all w : Worker | w in (Human + Robot) - (Human & Robot)
}

pred inv1_correct_15[] {
all w: Worker | w in Human => w not in Robot
all w: Worker | w not in Human => w in Robot
}

pred inv1_correct_16[] {
no Worker-Human&Worker-Robot
}

pred inv1_correct_17[] {
(Human + Robot) <: Worker = Worker
}

pred inv1_correct_18[] {
all x : Worker | one x & Human or one x & Robot
}

pred inv1_correct_19[] {
all ws: Worker | ws in Human or ws in Robot
}

pred inv1_correct_20[] {
no Worker - Robot - Human
}

pred inv1_correct_21[] {
no ((Human <: Worker) & (Robot <: Worker))
Human + Robot = Worker
}

pred inv1_correct_22[] {
all worker : Worker | worker in Human or worker in Robot
}

pred inv1_correct_23[] {
Human + Robot = Worker
}

pred inv1_correct_24[] {
all w : Worker - Human - Robot | w not in Worker
}

pred inv1_correct_25[] {
(Human + Robot) & Worker = Worker
}

pred inv1_correct_26[] {
all work: Worker | work in Human or work in Robot
}

pred inv1_correct_27[] {
Worker = (Human - Robot) + (Robot - Human)
}

