sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File = Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004849 { not ((inv2 and ((some capBenchS or no CapBenchB) or some capBenchS)) and ((no CapBenchA and some CapBenchB) and some CapBenchA)) }
pred cap004849c { ((not ((no CapBenchA and some CapBenchB) and some CapBenchA)) or (not (inv2 and ((some capBenchS or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004849 { cap004849 iff cap004849c }
check CapBenchEquivalent_cap004849 for 4
