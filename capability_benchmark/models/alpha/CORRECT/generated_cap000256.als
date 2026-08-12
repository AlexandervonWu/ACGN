sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
all f1, f2, f3 : File | (f1 -> f2 in link && f1 -> f3 in link) => f2 = f3
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000256 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
pred cap000256c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000256 { cap000256 iff cap000256c }
check CapBenchEquivalent_cap000256 for 4
