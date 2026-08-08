module alloy4fun_augmented_trainStationNew_inv8
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv8_oracle[] {
all e : Entry, x : Exit | x in e.*succs
}

pred inv8_correct_0[] {
all ex : Exit | all en : Entry | ex in en.*(succs)
}

pred inv8_correct_1[] {
all x : Exit | all e : Entry | x in e.*succs
}

pred inv8_correct_2[] {
all t1,t2:Track | t1 in Entry and t2 in Exit implies t1->t2 in *succs
}

pred inv8_correct_3[] {
all x : Entry | Exit in x.*succs
}

pred inv8_correct_4[] {
all e : Entry | all ex : Exit | ex in e.^succs or e=ex
}

pred inv8_correct_5[] {
all e:Entry | ((e.^succs + e) & Exit) = Exit
}

pred inv8_correct_6[] {
all e: Entry| all c: Exit| c in e.*(succs)
}

pred inv8_correct_7[] {
all disj t1,t2:Track | t1 in Entry && t2 in Exit implies t2 in t1.^(succs)
}

pred inv8_correct_8[] {
all t1,t2:Track | t1!=t2 and one (t1 & Entry) and one (t2 & Exit) implies t2 in t1.^succs
}

pred inv8_correct_9[] {
all t1,t2:Track | t1 in Entry and t2 in Exit and t1!=t2 implies t2 in t1.^(succs)
}

pred inv8_correct_10[] {
all en : Entry | all ex : Exit | ex in en.^succs or ex=en
}

pred inv8_correct_11[] {
all t: Track | some t&Entry implies (Exit in t.*succs)
}

pred inv8_correct_12[] {
all e : Entry | Exit = (e.*succs)&Exit
}

pred inv8_correct_13[] {
all e: Entry | all f: Exit | f in e.*(succs)
}

pred inv8_correct_14[] {
all e:Entry | all ex:Exit | e->ex in *succs
}

pred inv8_correct_15[] {
all en : Entry, ex : Exit | ex in en.*succs
}

pred inv8_correct_16[] {
all e : Entry | Exit in e.*succs
}

pred inv8_correct_17[] {
all t: Entry | all e: Exit | e in t.*succs
}

pred inv8_correct_18[] {
all t1, t2 : Track | t1 != t2 and t1 in Entry and t2 in Exit implies t2 in t1.^succs
}

pred inv8_correct_19[] {
Entry->Exit in *succs
}

pred inv8_correct_20[] {
all e : Entry | Exit in e.^succs + e
}

pred inv8_correct_21[] {
all entry : Entry | all exit : Exit | exit in entry.^succs or exit=entry
}

pred inv8_correct_22[] {
all en : Entry | all ex : Exit | ex in en.*(succs)
}

pred inv8_correct_23[] {
all et : Entry, ex : Exit | ex in et.*succs
}

pred inv8_correct_24[] {
all ex : Exit | all en : Entry | ex in en.^(succs) or ex=en
}

pred inv8_correct_25[] {
all entry : Entry | all exit : Exit | exit in entry.^succs or entry=exit
}

pred inv8_correct_26[] {
all disj x,y:Track| x in Entry and y in Exit => y in x.^(succs)
}

pred inv8_correct_27[] {
all entry : Entry, exit : Exit  | exit in entry.*succs
}

pred inv8_correct_28[] {
all en : Entry | all ex : Exit | ex in en.^(succs) or en=ex
}

pred inv8_correct_29[] {
all e: Entry | all ex : Exit |  ex in e.*succs
}

pred inv8_correct_30[] {
all ex : Exit, en: Entry | ex in en.*succs
}

pred inv8_correct_31[] {
all exit : Exit | all entry : Entry | exit in entry.*(succs)
}

pred inv8_correct_32[] {
all e:Entry, ex:Exit | e->ex in *succs
}

pred inv8_correct_33[] {
all e: Entry, s: Exit | s in e.*(succs)
}

pred inv8_correct_34[] {
all e : Entry | e.(*succs :> Exit) = Exit
}

pred inv8_correct_35[] {
all e: Entry , ex : Exit | e != ex =>  ex in e.^succs
}

pred inv8_correct_36[] {
all e : Entry, ex : Exit | ex in e.*succs
}

pred inv8_correct_37[] {
all e: Entry | all x: Exit | x in e.^succs or e = x
}

pred inv8_correct_38[] {
all disj t,t1:Track | t in Entry and t1 in Exit implies t1 in t.^succs
}

pred inv8_correct_39[] {
all e : Entry | all x : Exit | x in e.*succs
}

pred inv8_correct_40[] {
all e: Exit, t: Entry | e in t.*succs
}

pred inv8_correct_41[] {
all x : Entry | all y : Exit | y in x.^succs or x = y
}

pred inv8_correct_42[] {
all e : Entry, x : Exit | e != x implies x in e.(^succs)
}

pred inv8_correct_43[] {
all disj en, ex: Track | en in Entry && ex in Exit implies ex in en.^(succs)
}

pred inv8_correct_44[] {
all ent : Entry | all ext : Exit | ext != ent implies ext in ent.^succs
}

pred inv8_correct_45[] {
all x : Track, y:Track-x | x in Entry && y in Exit => y in x.^(succs)
}

pred inv8_correct_46[] {
all ex, ent: Track | ex in Exit and ent in Entry implies ex in ent.*(succs)
}

pred inv8_correct_47[] {
all en : Entry | all e : Exit-en | e in en.^succs
}

pred inv8_correct_48[] {
all en, ex : Track | en in Entry and ex in Exit and en != ex implies ex in en.^succs
}

pred inv8_correct_49[] {
all t1:Entry,t2:Exit | t1->t2 in *succs
}

