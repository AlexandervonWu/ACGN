module alloy4fun_augmented_productionLineNew_inv5
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

pred inv5_oracle[] {
all c : Workstation | no (c.workers & Human) or no (c.workers & Robot)
}

pred inv5_correct_0[] {
all w: Workstation | no (w.workers & Robot) or no (w.workers & Human)
}

pred inv5_correct_1[] {
all x, y: Worker,  z,w: Workstation | x in Robot and y in Human and x in z.workers and y in w.workers implies z != w
}

pred inv5_correct_2[] {
all ws : Workstation, h : Human, r : Robot | h in ws.workers implies r not in ws.workers
}

pred inv5_correct_3[] {
all w : Workstation | (some Human & w.workers) implies (no Robot & w.workers)
}

pred inv5_correct_4[] {
all x:Human, y:Robot | no workers.x & workers.y
}

pred inv5_correct_5[] {
all ws : Workstation, w : Worker | w in ws.workers && w in Human implies (all w1 : Worker | w1 in ws.workers implies w1 not in Robot)
}

pred inv5_correct_6[] {
all w: Workstation| all h: Human| all r: Robot| h in w.workers => r not in w.workers
}

pred inv5_correct_7[] {
all h : Human, r : Robot | no (workers.h & workers.r)
}

pred inv5_correct_8[] {
all x:Workstation|all y,w:Worker | y in Robot and y in x.workers and w in Human implies w not in x.workers
}

pred inv5_correct_9[] {
all ws : Workstation | (ws.workers & Human) = none or (ws.workers & Robot) = none
}

pred inv5_correct_10[] {
all ws : Workstation | some Human & ws.workers implies no Robot & ws.workers
all ws : Workstation | some Robot & ws.workers implies no Human & ws.workers
}

pred inv5_correct_11[] {
all ws : Workstation |  no (ws.workers & Robot) or no (ws.workers & Human)
}

pred inv5_correct_12[] {
all  wt : Workstation | (wt.workers in Worker - Human) or (wt.workers in Worker - Robot)
}

pred inv5_correct_13[] {
all w: Workstation | no w.workers or (no w.workers & Robot) or (no w.workers & Human)
}

pred inv5_correct_14[] {
no workers.Human & workers.Robot
}

pred inv5_correct_15[] {
all w:Workstation | no (w.workers & Human) or no (w.workers & Robot)
}

pred inv5_correct_16[] {
all h: Human| all r: Robot| all w: Workstation| (h in w.workers implies r not in w.workers) && (r in w.workers implies h not in w.workers)
}

pred inv5_correct_17[] {
all h:Human, r:Robot, wk1:Workstation, wk2:Workstation | h in wk1.workers and r in wk2.workers implies wk1 != wk2
}

pred inv5_correct_18[] {
(all h: Human| all r: Robot| all w: Workstation| h in w.workers implies r not in w.workers)
&& (all h: Human| all r: Robot| all w: Workstation| r in w.workers implies h not in w.workers)
}

pred inv5_correct_19[] {
all h : Human | all r : Robot | all ws : Workstation | (r in ws.workers) implies (not(h in ws.workers))
}

pred inv5_correct_20[] {
all h:Human, r:Robot, ws:Workstation | h in ws.workers implies r not in ws.workers
}

pred inv5_correct_21[] {
all ws: Workstation, r: Robot, h: Human | h in ws.workers => r not in ws.workers
}

pred inv5_correct_22[] {
all h : Human | all r : Robot | all ws : Workstation | (h in ws.workers => r not in ws.workers) and (r in ws.workers => h not in ws.workers)
}

pred inv5_correct_23[] {
all x, y: Worker, z, w: Workstation | x in Human and y in Robot and x in z.workers and y in w.workers implies z != w
}

pred inv5_correct_24[] {
all ws : Workstation | all h : Human, r : Robot | h in ws.workers => r not in ws.workers
}

pred inv5_correct_25[] {
all x, y: Worker | all z,w: Workstation | x in Robot and y in Human and x in z.workers and y in w.workers implies z != w
}

pred inv5_correct_26[] {
all w:Workstation, wo:Worker | no (w.workers & Human) or no (w.workers & Robot)
}

pred inv5_correct_27[] {
all ws: Workstation | all w1,w2:Worker | w1 in ws.workers and w2 in ws.workers and w1 in Human implies w2 not in Robot
}

pred inv5_correct_28[] {
all w : Workstation | all h : Human | all r : Robot | ((h in w.workers) implies (r not in w.workers)) and ((r in w.workers) implies (h not in w.workers))
}

pred inv5_correct_29[] {
all ws:Workstation, h:Human, r:Robot | not (h in ws.workers and r in ws.workers)
}

pred inv5_correct_30[] {
all w:Workstation,r:Robot,h:Human| r not in w.workers or h not in w.workers
}

pred inv5_correct_31[] {
all x1,x2 : Worker | all y : Workstation | x1 in Human and x2 in Robot and x1 in y.workers implies x2 not in y.workers
all x1,x2 : Worker | all y : Workstation | x1 in Human and x2 in Robot and x2 in y.workers implies x1 not in y.workers
}

pred inv5_correct_32[] {
all x1,x2 : Worker | all y : Workstation | x1 in Human and x2 in Robot and x1 in y.workers implies x2 not in y.workers
}

