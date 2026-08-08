module alloy4fun_augmented_productionLineNew_inv9
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

pred inv9_oracle[] {
all w : Workstation - end | one w.succ
	no end.succ
	Workstation in begin.*succ
}

pred inv9_correct_0[] {
all w:Workstation | ((w in begin and w in end and no w.succ and no succ.w) or (w in begin and w not in end and no succ.w and #w.succ=1) or (w in end and w not in begin and no w.succ and #succ.w=1) or (w not in end and w not in begin and #w.succ=1 and #succ.w=1))and w not in w.^succ and w not in ^succ.w
}

pred inv9_correct_1[] {
all w:Workstation | (( w in begin and #w.succ=1 and #succ.w=0  ) or ( w in end and #w.succ=0 and #succ.w=1   ) or ( #w.succ=1 and #succ.w=1 ) or (w in begin and w in end and #w.succ=0 and #succ.w=0)) and w not in w.^succ and w not in ^succ.w
}

pred inv9_correct_2[] {
all wc: Workstation | wc not in wc.^succ
all wc: Workstation | (wc in begin and #wc.succ = 1 and all wc2: Workstation - wc | wc2 in wc.^succ) or
(wc in end and wc.succ = none) or
(wc not in begin and wc not in end and #wc.succ = 1 and one wc3: Workstation - wc | wc3.succ = wc)
}

pred inv9_correct_3[] {
all w : Workstation-begin | (w in begin.^succ)
all w : Workstation | w not in w.^succ
all w : Workstation-end | one w.succ
}

pred inv9_correct_4[] {
all w,wb : Workstation | (wb in begin and w!=wb) implies w in wb.^(succ)
all w : Workstation | w not in w.^(succ)
all w : Workstation | w not in end implies one w.succ
}

pred inv9_correct_5[] {
all w, wb: Workstation|(wb in begin and w!=wb) implies w in wb.^(succ)
all w: Workstation| w not in end implies one w.succ
all w: Workstation| w not in w.^(succ)
}

pred inv9_correct_6[] {
no (iden & ^succ)
Workstation in begin.*succ
no end.succ
no succ.begin
all ws : Workstation | lone ws.succ
}

pred inv9_correct_7[] {
all ws:Workstation-end| one ws.succ and begin not in ws.succ
all ws:Workstation-begin| ws in begin.^succ
no end.succ
}

pred inv9_correct_8[] {
all w,wb:Workstation | (wb in begin and wb!=w) implies w in wb.^(succ)
all w: Workstation | w not in w.^(succ)
all w: Workstation | w not in end implies one w.succ
}

pred inv9_correct_9[] {
all b, w : Workstation | b in begin and b != w implies w in b.^succ
all w : Workstation | w not in w.^succ
all w : Workstation | w not in end implies one w.succ
}

pred inv9_correct_10[] {
all w : Workstation | w not in w.^succ
all w : Workstation | no w.succ => w in end
all w : Workstation | no succ.w => w in begin
all w : Workstation | (w not in end) => one w.succ
}

pred inv9_correct_11[] {
end in begin.*succ
begin in *succ.end
succ in (Workstation-end) lone -> one Workstation
succ in Workstation one -> lone (Workstation-begin)
no iden & ^succ
}

