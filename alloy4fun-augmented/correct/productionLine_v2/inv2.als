module alloy4fun_augmented_productionLine_v2_inv2
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
(all ws : Workstation | some w : Worker | ws->w in workers)
and
(all w : Worker | one ws : Workstation | ws->w in workers)
}

pred inv2_correct_1[] {
all wk:Workstation | some w:Worker | w in wk.workers
all w:Worker | one wk:Workstation | w in wk.workers
}

pred inv2_correct_2[] {
all wb : Workstation | some wb.workers
all w : Worker | one wb : Workstation | w in wb.workers
}

pred inv2_correct_3[] {
all w : Workstation | some w . workers
all w : Worker | one workers . w
}

pred inv2_correct_4[] {
all ws:Workstation | some w:Worker | w in ws.workers
all w:Worker | one ws:Workstation | w in ws.workers
}

pred inv2_correct_5[] {
all x : Workstation | some x.workers
all x : Worker | some y : Workstation | one x & y.workers and no x & (Workstation-y).workers
}

pred inv2_correct_6[] {
all x : Workstation | some x.workers
all x : Worker | one workers.x
}

pred inv2_correct_7[] {
all ws: Workstation| some ws.workers
all w: Worker | one w.~workers
}

pred inv2_correct_8[] {
all ws: Workstation | some ws.workers
all w: Worker | one ws: Workstation | ws->w in workers
}

pred inv2_correct_9[] {
all w : Workstation | some w.workers
all w : Worker | one wor : Workstation | w in wor.workers
}

pred inv2_correct_10[] {
(all w : Workstation | some w.workers) and (all t : Worker | one workers.t)
}

pred inv2_correct_11[] {
all ws : Workstation | some w : Worker | ws->w in workers
workers in Workstation one -> set Worker
}

pred inv2_correct_12[] {
all ws : Workstation | some ws.workers
all w : Worker | one ws : Workstation | w in ws.workers
}

pred inv2_correct_13[] {
all ws1,ws2 : Workstation | all w1 : Worker | w1 in ws1.workers and w1 in ws2.workers implies ws1=ws2
all ws : Workstation | some ws.workers
all w : Worker | w in Workstation.workers
}

pred inv2_correct_14[] {
all w:Worker | one workers.w

Workstation = workers.Worker
}

pred inv2_correct_15[] {
all w:Workstation | some w.workers
all w:Worker | one w.~workers
}

pred inv2_correct_16[] {
all ws : Workstation | some ws.workers
all w : Worker | w in Workstation.workers
all w1,w2 : Worker | all ws1,ws2: Workstation | ws1!=ws2 and w1 in ws1.workers and w2 in ws2.workers implies w1!=w2
}

pred inv2_correct_17[] {
all w:Worker | one ww:Workstation | w in ww.workers
all ww:Workstation | some (ww.workers)
}

pred inv2_correct_18[] {
all w : Workstation | some w.workers
Workstation.workers = Worker
all w : Worker | all disj w1,w2 : Workstation | w in w1.workers and w in w2.workers implies w1=w2
}

pred inv2_correct_19[] {
all w:Worker | one workers.w
all w:Workstation | some w.workers
}

pred inv2_correct_20[] {
all w : Workstation | some w.workers
and
all t : Worker | one workers.t
}

pred inv2_correct_21[] {
all ws: Workstation | some ws.workers
all w: Worker | one workers.w
}

pred inv2_correct_22[] {
all w:Workstation | some w.workers
all w:Worker | one ws:Workstation| w in ws.workers
}

pred inv2_correct_23[] {
all ws: Workstation | ws.workers != none and (all w: Worker | one wks: Workstation | w in wks.workers)
}

pred inv2_correct_24[] {
all wtt : Workstation | some wtt.workers

all w : Worker | one wtt : Workstation | w in wtt.workers
}

pred inv2_correct_25[] {
all w1,w2 : Worker | all ws1,ws2: Workstation | ws1!=ws2 and w1 in ws1.workers and w2 in ws2.workers implies w1!=w2
all ws : Workstation | some w : Worker | w in ws.workers
all w : Worker | w in Workstation.workers
}

pred inv2_correct_26[] {
all w: Workstation | some wo : Worker | wo in w.workers
and
all wo : Worker | one w: Workstation | wo in w.workers
}

pred inv2_correct_27[] {
Workstation in workers.Worker
all w : Worker | one ww : Workstation | w in ww.workers
}

pred inv2_correct_28[] {
all w:Worker | one w.~workers
all w:Workstation | some w.workers
}

pred inv2_correct_29[] {
all w : Workstation | some w.workers and all w : Worker | one workers.w
}

pred inv2_correct_30[] {
all ws : Workstation | ws.workers != none and (all w : Worker | one ws : Workstation | w in ws.workers)
}

pred inv2_correct_31[] {
all ws:Workstation |some w1:Worker | ws->w1 in workers
all w:Worker | one ws:Workstation | ws->w in workers
}

pred inv2_correct_32[] {
all wk:Workstation | some wk.workers
all w:Worker | one wk:Workstation | w in wk.workers
}

pred inv2_correct_33[] {
all w1,w2 : Worker | all ws1,ws2: Workstation | ws1!=ws2 and w1 in ws1.workers and w2 in ws2.workers implies w1!=w2
all ws : Workstation | some ws.workers
all w : Worker | w in Workstation.workers
}

pred inv2_correct_34[] {
Workstation in workers.Worker and all w : Worker | one workers.w
}

pred inv2_correct_35[] {
all w : Workstation | some w.workers
all wr : Worker | one workers.wr
}

pred inv2_correct_36[] {
Worker.~workers = Workstation
all w : Worker | one ww : Workstation | w in ww.workers
}

pred inv2_correct_37[] {
(all ws : Workstation | some w1 : Worker | ws->w1 in workers)
(all w1 : Worker | one ws : Workstation | ws -> w1 in workers)
}

pred inv2_correct_38[] {
all w : Workstation | w.workers != none and (all worker : Worker | one workstation : Workstation | worker in workstation.workers)
}

pred inv2_correct_39[] {
(all w : Workstation | some t : Worker | w->t in workers) and (all t : Worker | one w : Workstation | w->t in workers)
}

pred inv2_correct_40[] {
all w:Worker | one ws : Workstation | ws->w in workers
all ws: Workstation | some w:Worker | ws->w in workers
}

pred inv2_correct_41[] {
all w: Workstation | some x : Worker | w->x in workers
all w: Worker | one x: Workstation | x->w in workers
}

pred inv2_correct_42[] {
all a1,a2:Workstation | (some b:Worker | a1->b in workers and a2->b in workers) implies a1 = a2
all b:Worker | some a:Workstation | a->b in workers
all a:Workstation | some b:Worker | a->b in workers
}

pred inv2_correct_43[] {
workers in Workstation one -> some Worker
all w,x : Workstation | w != x implies no (w.workers & x.workers)
}

pred inv2_correct_44[] {
all wt:Workstation | some w:Worker | (w in wt.workers)
all w:Worker | one wt:Workstation | (w in wt.workers)
}

pred inv2_correct_45[] {
all ws: Workstation| some ws.workers
all w: Worker | one w.~workers
all ws: Workstation, w: Worker | some ws.workers and one w.~workers
}

pred inv2_correct_46[] {
all w : Workstation | some wk : Worker | wk in w.workers
all wk : Worker | one w : Workstation | wk in w.workers
}

pred inv2_correct_47[] {
all s: Workstation | some w: Worker | w in s.workers
all w: Worker | one s: Workstation | s in workers.w
}

pred inv2_correct_48[] {
all w : Workstation | some wor : Worker | wor in w.workers and
all worker : Worker | one ws : Workstation | worker in ws.workers
}

pred inv2_correct_49[] {
all x : Workstation | some x.workers
all x : Worker | some y : Workstation | one (x & y.workers) - (x & (Workstation-y).workers)
}

pred inv2_correct_50[] {
all wks : Workstation | some w : Worker | wks->w in workers
all w : Worker | one wks: Workstation | wks->w in workers
}

pred inv2_correct_51[] {
all w : Workstation | some w.workers
all w : Worker | one ww : Workstation | w in ww.workers
}

pred inv2_correct_52[] {
all w : Workstation | w.workers!=none
all t : Worker | one w : Workstation | t in w.workers
}

pred inv2_correct_53[] {
all ws : Workstation | some w : Worker | w in ws.workers
and
all w : Worker | one ws:Workstation | w in ws.workers
}

pred inv2_correct_54[] {
(all ws : Workstation | ws.workers != none) and (all w : Worker | one ws : Workstation | w in ws.workers)
}

pred inv2_correct_55[] {
all s : Workstation | some w : Worker | w in s.workers
all w : Worker | one s : Workstation | w in s.workers
}

pred inv2_correct_56[] {
all ws : Workstation | some w : Worker | ws->w in workers
all w : Worker | some ws1 : Workstation | ws1->w in workers and all ws2 : Workstation | ws2->w in workers implies ws1 = ws2
}

pred inv2_correct_57[] {
all ws: Workstation | not no ws.workers
all worker: Worker | one ws: Workstation | worker in ws.workers
}

pred inv2_correct_58[] {
all w: Workstation | some wo: Worker | w->wo in workers

all w: Worker | one work: Workstation | work->w in workers
}

pred inv2_correct_59[] {
all w: Workstation | some w.workers
all w: Workstation, wo: Worker | one workers.wo
}

pred inv2_correct_60[] {
all w1,w2 : Workstation | w1.workers!=none and w2.workers!=none
all t : Worker | one w : Workstation | t in w.workers
}

pred inv2_correct_61[] {
all w : Workstation | some wo : Worker | w -> wo in workers and all wwo : Worker | one ww : Workstation | ww -> wwo in workers
}

