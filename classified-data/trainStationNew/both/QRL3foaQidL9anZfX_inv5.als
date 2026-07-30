sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t: Track, t2: Track, t3: Track | t != t2 && t2 != t3 && t != t3 && t in t2.succs && t in t3.succs => t in Junction and t2 not in t2.succs && t3 not in t3.succs
}

pred inv5c {
	all t : Track | t not in Junction iff lone succs.t
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 

