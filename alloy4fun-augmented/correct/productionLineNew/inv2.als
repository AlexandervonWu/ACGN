module alloy4fun_augmented_productionLineNew_inv2
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

pred inv2_oracle[] {
workers in Workstation one -> some Worker
}

pred inv2_correct_0[] {
(all s : Workstation | some w : Worker | w in s.workers)
and
(all w : Worker | one ws : Workstation| w in ws.workers)
}

pred inv2_correct_1[] {
all w:Workstation| #w.workers>0
all w:Worker | #workers.w=1
}

pred inv2_correct_2[] {
all w : Workstation | some w.workers
all w : Worker | one work : Workstation | w in work.workers
}

pred inv2_correct_3[] {
all ws : Workstation | some ws.workers
all w : Worker | one workers.w
}

pred inv2_correct_4[] {
(all w: Workstation | some r: Worker | r in w.workers) && (all w: Worker | one workers.w)
}

pred inv2_correct_5[] {
all w: Workstation | some wo: Worker |wo in w.workers
all w: Worker | (one work : Workstation | w in work.workers)
}

pred inv2_correct_6[] {
all ws : Workstation | some w : Worker | w in ws.workers
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_7[] {
all x: Workstation | some y : Worker | y in x.workers
all x: Worker | some y : Workstation | x in y.workers
all x: Worker | all y, z : Workstation | x in y.workers and x in z.workers implies y = z
}

pred inv2_correct_8[] {
all wo:Worker | one w:Workstation | wo in w.workers
all w:Workstation | some wo:Worker | wo in w.workers
}

pred inv2_correct_9[] {
all w : Worker | one wor : Workstation | w in wor.workers
all wor : Workstation | some wor.workers
}

pred inv2_correct_10[] {
all w : Workstation | some (w.workers)
all w : Worker | one (w.~workers)
}

pred inv2_correct_11[] {
all x: Workstation | some (x.workers) && all y: Worker | one (workers.y)
}

pred inv2_correct_12[] {
all w : Workstation | #w.workers>0
all worker : Worker | #workers.worker=1
}

pred inv2_correct_13[] {
all ws: Workstation | some w:Worker | w in ws.workers
all w: Worker | one work : Workstation | w in work.workers
}

pred inv2_correct_14[] {
all x:Workstation | some x.workers
all x:Worker | one workers.x
}

pred inv2_correct_15[] {
(all x: Workstation| some w: Worker| w in x.workers) && (all w: Worker| one workers.w)
}

pred inv2_correct_16[] {
all ws : Workstation | ws.workers != none
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_17[] {
all ws : Workstation | some ws.workers
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_18[] {
all ws: Workstation | some ws.workers
all w: Worker | one w.~workers
}

pred inv2_correct_19[] {
(all ws : Workstation | some ws.workers) and (all wo : Worker | one workers.wo)
}

pred inv2_correct_20[] {
all ws:Workstation | some w:Worker | w in ws.workers and (all wk:Worker | one ws1:Workstation | wk in ws1.workers)
}

pred inv2_correct_21[] {
(all ws: Workstation | some w: Worker | ws -> w in workers)
and
(all w:Worker | one ws:Workstation | ws -> w in workers)
}

pred inv2_correct_22[] {
all ws: Workstation | some ws.workers  &&  all  w: Worker | one w.~workers
}

pred inv2_correct_23[] {
all w: Workstation | some w.workers
all w: Worker | one workers.w
}

pred inv2_correct_24[] {
all w : Worker | one ws: Workstation | some w & ws.workers
all ws: Workstation | some ws.workers
}

pred inv2_correct_25[] {
all p: Workstation | some p.workers
all x: Worker | one v: Workstation | x in v.workers
}

pred inv2_correct_26[] {
all a:Worker|(one w:Workstation | a in w.workers)
all w:Workstation | some w.workers
}

pred inv2_correct_27[] {
all trab : Worker |one w : Workstation |  trab in w.workers
all w : Workstation | #(w.workers)>0
}

pred inv2_correct_28[] {
all x : Workstation | #(x.workers) > 0
all x : Worker | one y : Workstation | x in y.workers
}

pred inv2_correct_29[] {
all w: Worker |
one ws: Workstation |
w in ws.workers
all ws: Workstation |
some w: Worker |
w in ws.workers
}

pred inv2_correct_30[] {
all ws : Workstation | #ws.workers > 0
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_31[] {
all w : Worker | one ws: Workstation | one w & ws.workers
all ws: Workstation | some ws.workers
}

pred inv2_correct_32[] {
all x: Workstation | some (x.workers)
all y: Worker | one (workers.y)
}

pred inv2_correct_33[] {
( all work : Workstation | some w : Worker | work->w in workers)
and
(all w : Worker | one ws : Workstation | ws->w in workers)
}

pred inv2_correct_34[] {
workers in Workstation one -> some Worker
all w,x : Workstation | w != x implies no (w.workers & x.workers)
}

pred inv2_correct_35[] {
all ws: Workstation | some w: Worker | ws -> w in workers
and
all w:Worker | one ws:Workstation | ws -> w in workers
}

pred inv2_correct_36[] {
all s : Workstation | some s.workers
all w : Worker | one s : Workstation | w in s.workers
}

pred inv2_correct_37[] {
all wk:Workstation | some w:Worker | wk in workers.w and (all w2:Worker | one wk2:Workstation | w2 in wk2.workers)
}

pred inv2_correct_38[] {
all w : Workstation | some w.workers
all worker : Worker |  one workers.worker
}

pred inv2_correct_39[] {
all w : Worker | #(workers.w) = 1
all  wt : Workstation | #(wt.workers) > 0
}

pred inv2_correct_40[] {
all w : Workstation | some w.workers
all wo : Worker | one workers.wo
}

pred inv2_correct_41[] {
all x : Workstation | #(x.workers)>0

all x : Worker | one w :Workstation  | x in w.workers
}

pred inv2_correct_42[] {
all ws : Workstation | some w : Worker | #ws.workers > 0
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_43[] {
all ws : Workstation | some ws.workers
all ws,ws1 : Workstation, w : Worker | one workers.w
}

pred inv2_correct_44[] {
workers in Workstation one -> some Worker

all ws : Workstation | some ws.workers
}

pred inv2_correct_45[] {
all w: Worker | one ws: Workstation | w in ws.workers
all ws: Workstation | some ws.workers
}

pred inv2_correct_46[] {
all w : Worker | one (w.(~workers))
all ws : Workstation | some (ws.workers)
}

pred inv2_correct_47[] {
(all ws:Workstation | some w:Worker | w in ws.workers)
and
(all w1:Worker | one ws1:Workstation | w1 in ws1.workers)
}

pred inv2_correct_48[] {
all ws : Workstation | #ws.workers > 0
all w: Worker | (one work : Workstation | w in work.workers)
}

pred inv2_correct_49[] {
all ws : Workstation | some w : Worker | w in ws.workers and (all w2 : Worker | one work : Workstation | w2 in work.workers)
}

pred inv2_correct_50[] {
all W:Workstation | some W.workers
all w:Worker | one W:Workstation | w in W.workers
}

pred inv2_correct_51[] {
all w: Workstation | some w.workers
all w1: Worker | one works: Workstation | w1 in works.workers
}

pred inv2_correct_52[] {
all a : Workstation | some a.workers
all b : Worker | one workers.b
}

pred inv2_correct_53[] {
(all w: Workstation| some p: Worker| p in w.workers) && (all p: Worker| one workers.p)
}

pred inv2_correct_54[] {
(all ws : Workstation | (some w : Worker | w in ws.workers)) and (all w :Worker | one ws : Workstation | ws in workers.w)
}

pred inv2_correct_55[] {
some workers
workers in Workstation one -> some Worker
}

