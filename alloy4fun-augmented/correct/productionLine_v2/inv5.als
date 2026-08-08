module alloy4fun_augmented_productionLine_v2_inv5
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
all w: Workstation | no w.workers & Robot or no w.workers &Human
}

pred inv5_correct_1[] {
all w : Workstation, h : Human | h in w.workers implies (Robot & w.workers) = none
}

pred inv5_correct_2[] {
all h: Human, r: Robot, ws: Workstation | h not in ws.workers or r not in ws.workers
}

pred inv5_correct_3[] {
all h : Human | all r : Robot | all w : Workstation | h in w.workers implies r not in w.workers
}

pred inv5_correct_4[] {
all w : Workstation | no Robot->Human & w.workers->w.workers
}

pred inv5_correct_5[] {
all h : Human, r : Robot, ws : Workstation | h in ws.workers implies r not in ws.workers
}

pred inv5_correct_6[] {
all h:Human, ws:Workstation | ws->h in workers implies all r:Robot | ws->r not in workers
all r:Robot, ws:Workstation | ws->r in workers implies all h:Human | ws->h not in workers
}

pred inv5_correct_7[] {
all h : Human, r : Robot, w : Workstation | (w->h in workers implies w->r not in workers) and (w->r in workers implies w->h not in workers)
}

pred inv5_correct_8[] {
all w : Workstation, h:Human, r:Robot | h in w.workers implies r not in w.workers
}

pred inv5_correct_9[] {
all ws:Workstation | not some w1, w2:Worker | (ws->w1 + ws->w2) in workers and w1 in Human and w2 in Robot and w1!=w2
}

pred inv5_correct_10[] {
all h: Human | all r: Robot | all ws: Workstation | h in ws.workers implies r not in ws.workers
}

pred inv5_correct_11[] {
all wk:Workstation, h:Human, r:Robot | h in wk.workers => r not in wk.workers
}

pred inv5_correct_12[] {
no (workers.Human & workers.Robot)
}

pred inv5_correct_13[] {
all w : Workstation | some w.workers & Robot implies no w.workers & Human
all w : Workstation | some w.workers & Human implies no w.workers & Robot
}

pred inv5_correct_14[] {
all ww:Workstation | some (ww.workers & Human) implies no (ww.workers & Robot)
}

pred inv5_correct_15[] {
all w1: Workstation, r:Robot, h:Human | r in w1.workers implies h not in w1.workers
}

pred inv5_correct_16[] {
all w:Workstation, h:Human , r:Robot | h not in w.workers or r not in w.workers
}

pred inv5_correct_17[] {
all w : Workstation | no Human->Robot & w.workers->w.workers
}

pred inv5_correct_18[] {
all w: Workstation, h: Human, r: Robot | (h in w.workers implies r not in w.workers) and (r in w.workers implies h not in w.workers)
}

pred inv5_correct_19[] {
all x : Workstation | no x.workers & Human or no x.workers & Robot
}

pred inv5_correct_20[] {
all w:Workstation | no Human&w.workers or no Robot&w.workers
}

pred inv5_correct_21[] {
all w : Workstation | all r : Robot | all h : Human | r in w.workers implies h not in w.workers
}

pred inv5_correct_22[] {
all w : Workstation| some w.workers & Robot => no w.workers & Human
}

pred inv5_correct_23[] {
all w:Workstation | no h:Human,r:Robot | w->h in workers and w->r in workers
}

pred inv5_correct_24[] {
all h:Human, r:Robot, w:Workstation | (w->h in workers implies w->r not in workers) or (w->r in workers implies w->h not in workers)
}

pred inv5_correct_25[] {
no Robot.~workers & Human.~workers
}

pred inv5_correct_26[] {
all h: Human | all w : Workstation | w->h in workers implies all r : Robot | w->r not in workers
}

pred inv5_correct_27[] {
all w: Workstation | some (Robot & w.workers) implies no (Human & w.workers)
}

pred inv5_correct_28[] {
all s:Workstation, h:Human, r:Robot |h not in s.workers or r not in s.workers
}

pred inv5_correct_29[] {
all h : Human | all r : Robot | all w : Workstation | (w->h in workers implies w->r not in workers) or (w->r in workers implies w->h not in workers)
}

pred inv5_correct_30[] {
all h : Human | all r : Robot | no (workers.h & workers.r)
}

pred inv5_correct_31[] {
all ws,r : univ | ws in Workstation and r in Robot and ws->r in workers implies all w : Worker | ws->w in workers implies w not in Human
all ws,h : univ | ws in Workstation and h in Human and ws->h in workers implies all w : Worker | ws->w in workers implies w not in Robot
}

pred inv5_correct_32[] {
all ws:Workstation, w1,w2:Worker | w1 in ws.workers and w2 in ws.workers and w1 in Human implies w2 not in Robot
}

pred inv5_correct_33[] {
all h : Human, r : Robot, w : Workstation | not (w -> h in workers and w -> r in workers)
}

pred inv5_correct_34[] {
all s : Workstation | all w1, w2 : Worker | w1 in s.workers and w2 in s.workers and w1 in Human implies w2 not in Robot
}

pred inv5_correct_35[] {
all h:Human, r:Robot, w:Workstation | (w->h in workers implies w->r not in workers)
}

pred inv5_correct_36[] {
all w : Workstation | all r : Robot | all h : Human | r in w.workers implies h not in w.workers
all w : Workstation | all r : Robot | all h : Human | h in w.workers implies r not in w.workers
}

pred inv5_correct_37[] {
all ws:Workstation | not some w1, w2:Worker | ws->w1 in workers and ws->w2 in workers and w1 in Human and w2 in Robot and w1!=w2
}

pred inv5_correct_38[] {
workers.Human & workers.Robot = none
}

pred inv5_correct_39[] {
all h : Human, ws : Workstation, r : Robot | h in ws.workers implies r not in ws.workers
}

pred inv5_correct_40[] {
all r : Robot | r not in (workers.Human).workers
all h : Human | h not in (workers.Robot).workers
}

pred inv5_correct_41[] {
all ws: Workstation, w: Worker | w in ws.workers and w in Human implies no Robot&ws.workers
}

pred inv5_correct_42[] {
all h : Human | all r : Robot | all w : Workstation | r in w.workers implies h not in w.workers
}

pred inv5_correct_43[] {
all w: Workstation, h: Human, r: Robot | w->h in workers => w->r !in workers
}

