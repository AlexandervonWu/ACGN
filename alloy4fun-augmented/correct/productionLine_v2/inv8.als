module alloy4fun_augmented_productionLine_v2_inv8
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

pred inv8_oracle[] {
all c : Component & Dangerous | no c.workstation.workers & Human
}

pred inv8_correct_0[] {
all c : Component | all w: Workstation |
c in Dangerous and w in c.workstation implies
(all h : Human | h not in w.workers)
}

pred inv8_correct_1[] {
all c: Component | c in Dangerous implies no (c.workstation.workers & Human)
}

pred inv8_correct_2[] {
all c : Component | all ws : Workstation | c in Dangerous and ws in c.workstation implies
(all h : Human | h not in ws.workers)
}

pred inv8_correct_3[] {
no Human&(Dangerous.workstation).workers
}

pred inv8_correct_4[] {
no Dangerous.workstation.workers & Human
}

pred inv8_correct_5[] {
all c:Component, h:Human | c in Dangerous => h not in c.workstation.workers
}

pred inv8_correct_6[] {
all d : Dangerous, h : Human, w : Workstation | d -> w in workstation => not w -> h in workers
}

pred inv8_correct_7[] {
all c: Component, ws: Workstation | c in Dangerous and c->ws in workstation implies no ws.workers&Human
}

pred inv8_correct_8[] {
no (Dangerous.workstation &workers . Human)
}

pred inv8_correct_9[] {
no (Component & Dangerous).workstation.workers & Human
}

pred inv8_correct_10[] {
all c:Dangerous, ws:c.workstation | c in Dangerous implies no w:ws.workers | w in Human
}

pred inv8_correct_11[] {
all c: Component, ws: c.workstation | c in Dangerous implies no w: ws.workers | w in Human
}

pred inv8_correct_12[] {
all c: Component, h:Human | c in Dangerous implies no c.workstation & workers.h
}

pred inv8_correct_13[] {
all c : Component | all w : Worker | (c in Dangerous and w in c.workstation.workers) implies w not in Human
}

pred inv8_correct_14[] {
all p: Component | all h: Human | all ws: Workstation |
p in Dangerous and h in ws.workers implies ws not in p.workstation
}

pred inv8_correct_15[] {
all c: Component, w: Workstation, h: Human | c in Dangerous and w in c.workstation implies h not in w.workers
}

pred inv8_correct_16[] {
all d : Dangerous | no d.workstation.workers&Human
}

pred inv8_correct_17[] {
all c:Dangerous, ws:c.workstation | no ws.workers & Human
}

pred inv8_correct_18[] {
all c: Component, w: Worker, ws: Workstation | c in Dangerous and ws in c.workstation and w in ws.workers implies w not in Human
}

pred inv8_correct_19[] {
all c:Dangerous,ws:c.workstation | all w: ws.workers | w not in Human
}

pred inv8_correct_20[] {
all c:Dangerous | no c.workstation.workers & Human
}

pred inv8_correct_21[] {
all d : Dangerous | d not in workstation.workers.Human
}

pred inv8_correct_22[] {
all c:Dangerous, ws:c.workstation, w:ws.workers | w not in Human
}

pred inv8_correct_23[] {
all c:Component,ws:c.workstation | c in Dangerous implies no w: ws.workers | w in Human
all c:Dangerous,ws:c.workstation | no w: ws.workers | w in Human
all c:Dangerous,ws:c.workstation,w: ws.workers | w not in Human
all c:Dangerous | no c.workstation.workers & Human
no Dangerous.workstation.workers & Human
}

pred inv8_correct_24[] {
all c: Dangerous, w: c.workstation.workers | w not in Human
}

pred inv8_correct_25[] {
no Human & (Component & Dangerous).workstation.workers
}

pred inv8_correct_26[] {
no (Dangerous & Component).workstation.workers & Human
}

pred inv8_correct_27[] {
all c:Component, ws:Workstation, w:Worker | c->ws in workstation and c in Dangerous and ws->w in workers implies w not in Human
}

pred inv8_correct_28[] {
all c:Dangerous,ws:c.workstation | no w: ws.workers | w in Human
}

pred inv8_correct_29[] {
all d:Dangerous | no Human&d.workstation.workers
}

pred inv8_correct_30[] {
all w:Workstation, d:Dangerous | d->w in workstation implies not some p:Human | w->p in workers
}

pred inv8_correct_31[] {
all c:Dangerous, ws:c.workstation.workers | no ws & Human
}

pred inv8_correct_32[] {
all c:Dangerous, h:Human | c in Component => h not in c.workstation.workers
}

pred inv8_correct_33[] {
all com: Component | all ws: Workstation | all h: Human | ws in com.workstation and com in Dangerous implies h not in ws.workers
}

pred inv8_correct_34[] {
all c:Component, ws:Workstation | c in Dangerous and c->ws in workstation => (not some h:Human| ws->h in workers)
}

pred inv8_correct_35[] {
all d,ws : univ | ws in Workstation and d in Dangerous and d->ws in workstation implies all w : Worker | ws->w in workers implies w not in Human
}

pred inv8_correct_36[] {
all d : Dangerous | all w : Workstation | all h : Human | w in d.workstation implies h not in w.workers
}

pred inv8_correct_37[] {
all d : Dangerous, h : Human | h not in (d.workstation).workers
}

pred inv8_correct_38[] {
Dangerous.workstation.workers & Human = none
}

pred inv8_correct_39[] {
all c: Component | c in Dangerous => no (Human & c.workstation.workers)
}

