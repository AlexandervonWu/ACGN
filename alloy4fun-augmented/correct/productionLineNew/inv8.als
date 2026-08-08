module alloy4fun_augmented_productionLineNew_inv8
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
all c: Component & Dangerous | all x : c.workstation | no (x.workers & Human)
}

pred inv8_correct_1[] {
all c: Component, h: Human |
(c in Dangerous) => (h !in c.workstation.workers)
}

pred inv8_correct_2[] {
no (workers.Human & Dangerous.workstation)
}

pred inv8_correct_3[] {
no Dangerous.workstation & workers.Human
}

pred inv8_correct_4[] {
all c : Component | c in Dangerous implies #(c.workstation.workers & Human) = 0
}

pred inv8_correct_5[] {
all c: Component | c in Dangerous implies (no c.workstation.workers & Human)
}

pred inv8_correct_6[] {
all d: Dangerous, ws : d.workstation | no (ws.workers & Human)
}

pred inv8_correct_7[] {
all c : Component & Dangerous | all w : c.workstation | no (w.workers & Human)
}

pred inv8_correct_8[] {
all d: Component & Dangerous | all x : d.workstation | no (x.workers & Human)
}

pred inv8_correct_9[] {
all c:Component, h:Human, ws:Workstation | c in Dangerous and ws in c.workstation implies (h not in ws.workers)
}

pred inv8_correct_10[] {
all c : Component, wk: Workstation | c in Dangerous and wk in c.workstation implies (all h : Human | h not in wk.workers)
}

pred inv8_correct_11[] {
all d:Dangerous & Component, c:d.workstation | no (c.workers & Human)
}

pred inv8_correct_12[] {
no ((Component & Dangerous).workstation.workers) & Human
}

pred inv8_correct_13[] {
all d : Dangerous, h : Human, ws1, ws2 : Workstation | h in ws1.workers and ws2 in d.workstation implies ws1 != ws2
}

pred inv8_correct_14[] {
all c:Component, ws:Workstation | c in Dangerous and ws in c.workstation implies( all h:Human | h not in ws.workers )
}

pred inv8_correct_15[] {
all d : Dangerous | all w : Worker | (w in d.workstation.workers) implies (w not in Human)
}

pred inv8_correct_16[] {
all c:Component | all ws:Workstation | c in Dangerous and ws in c.workstation implies (all h:Human | h not in ws.workers)
}

pred inv8_correct_17[] {
all c : Component, ws : c.workstation | c in Dangerous => no (Human & ws.workers)
}

pred inv8_correct_18[] {
all d : Dangerous | all w: d.workstation | no h : Human | h in w.workers
}

pred inv8_correct_19[] {
all c : Component | all h : Human | c in Dangerous => h not in c.workstation.workers
}

pred inv8_correct_20[] {
all c: Component & Dangerous, ws: c.workstation | no ws.workers & Human
}

pred inv8_correct_21[] {
all d:Dangerous, h:Human, ws:Workstation | ws in d.workstation implies h not in ws.workers
}

pred inv8_correct_22[] {
all c: Component| all x : c.workstation | c in Dangerous => no (x.workers & Human)
}

pred inv8_correct_23[] {
all p : Dangerous & Component | all ws : p.workstation | no Human & ws.workers
}

pred inv8_correct_24[] {
all c:Component| all ws:c.workstation| all w : ws.workers| c in Dangerous implies w not in Human
}

pred inv8_correct_25[] {
all dc : Component & Dangerous | no (dc.workstation.workers & Human)
}

pred inv8_correct_26[] {
all d:Dangerous & Component, c:d.workstation, w:Worker | w in c.workers => w not in Human
}

pred inv8_correct_27[] {
all c : Component & Dangerous | all ws : c.workstation | no (ws.workers & Human)
}

pred inv8_correct_28[] {
all c : Dangerous | (all h : Human | c not in workstation.workers.h)
}

pred inv8_correct_29[] {
all c:Product | c in Dangerous implies no (c.workstation.workers & Human)
}

pred inv8_correct_30[] {
all c: Component & Dangerous| all s: c.workstation| no (s.workers & Human)
}

pred inv8_correct_31[] {
all c : Dangerous & Component | all x : c.workstation | no ( x.workers & Human)
}

pred inv8_correct_32[] {
all c: Dangerous, ws : c.workstation | no (ws.workers & Human)
}

