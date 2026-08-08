module alloy4fun_augmented_trainStationNew_inv1
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1_oracle[] {
some Entry
	some Exit
}

pred inv1_correct_0[] {
some e: Entry, f: Exit | e in Track and f in Track
}

pred inv1_correct_1[] {
some t : Track | t in Entry
some t : Track | t in Exit
}

pred inv1_correct_2[] {
some ex:Exit, e:Entry | e in Track and ex in Track
}

pred inv1_correct_3[] {
some entry, exit: univ | entry in Entry and exit in Exit
}

pred inv1_correct_4[] {
some Entry->Exit
}

pred inv1_correct_5[] {
some t,x:Track| t in Entry and x in Exit
}

pred inv1_correct_6[] {
some Exit and some Entry
}

pred inv1_correct_7[] {
some en: Entry, ex :Exit | en in Track and ex in Track
}

pred inv1_correct_8[] {
some x : Entry | some y : Exit | x in Track and y in Track
}

pred inv1_correct_9[] {
some e: Exit, en: Entry | e in Track and en in Track
}

pred inv1_correct_10[] {
some Entry & Track and some Exit & Track
}

pred inv1_correct_11[] {
some t: Track | t in Entry and t in Track
some t: Track | t in Exit and t in Track
}

pred inv1_correct_12[] {
some x:Track | x in Entry
some x:Track | x in Exit
}

pred inv1_correct_13[] {
all e: Entry, x: Exit | some e && some x
some Entry && some Exit
}

pred inv1_correct_14[] {
some e:Entry, ex:Exit | e in Track and ex in Track
}

pred inv1_correct_15[] {
some t,a:Track| t in Entry and a in Exit
}

pred inv1_correct_16[] {
some en : Entry | some ex : Exit | en in Track and ex in Track
}

pred inv1_correct_17[] {
some e: univ | e in Entry
some x : univ | x in Exit
}

pred inv1_correct_18[] {
some e: Entry| some s: Exit| e in Track and s in Track
}

pred inv1_correct_19[] {
some ent : Entry | some exi : Exit | ent in Track and exi in Track
}

pred inv1_correct_20[] {
some ex : Exit , en : Entry | ex in Track and en in Track
}

pred inv1_correct_21[] {
not no Entry and not no Exit
}

pred inv1_correct_22[] {
some x: Entry, y : Exit | x in Track && y in Track
}

pred inv1_correct_23[] {
some ex : Exit | some e : Entry | ex in Track or e in Track
}

pred inv1_correct_24[] {
some a,b:Track| a in Entry and b in Exit
}

pred inv1_correct_25[] {
some t: Track | t in Entry and some t: Track | t in Exit
}

pred inv1_correct_26[] {
some y:Exit | some z:Entry | y in Track and z in Track
}

pred inv1_correct_27[] {
#Entry > 0 and #Exit > 0
}

pred inv1_correct_28[] {
some exit : Exit | some entry : Entry | exit in Track and entry in Track
}

pred inv1_correct_29[] {
some e : Entry | some ex : Exit | e in Track and ex in Track
}

pred inv1_correct_30[] {
some e: Entry| some t: Exit| e in Track and t in Track
}

pred inv1_correct_31[] {
some x : Entry | x in Track
some x : Exit | x in Track
}

pred inv1_correct_32[] {
#Entry >= 1
#Exit >= 1
}

pred inv1_correct_33[] {
some e : Entry | some s : Exit | (e+s) in Track
}

pred inv1_correct_34[] {
some e: Entry, ex: Exit | e in Track or ex in Track
}

pred inv1_correct_35[] {
some en : Track | en in Entry
some ex : Track | ex in Exit
}

pred inv1_correct_36[] {
some t1,t2 : Track | t1 in Entry and t2 in Exit
}

pred inv1_correct_37[] {
all x : univ | some Entry and some Exit
}

