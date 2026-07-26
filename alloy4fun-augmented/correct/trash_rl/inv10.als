module alloy4fun_augmented_trash_rl_inv10
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv10_oracle[] {
((Trash.link) in Trash)
}

pred inv10_correct_0[] {
(all f,f1: (one File) {
((((f->f1) in link) && (f in Trash)) => (f1 in Trash))
})
}

pred inv10_correct_1[] {
(all f: (one File) {
((f in Trash) => ((f.link) in Trash))
})
}

pred inv10_correct_2[] {
(all f,b: (one File) {
((((f->b) in link) && (f in Trash)) => (b in Trash))
})
}

pred inv10_correct_3[] {
(all f: (one File) {
(all f1: (one File) {
((((f->f1) in link) && (f in Trash)) => (f1 in Trash))
})
})
}

pred inv10_correct_4[] {
(all f: (one Trash) {
((f.link) in Trash)
})
}

pred inv10_correct_5[] {
(all f: (one File) {
((f in Trash) => ((f.(^link)) in Trash))
})
}

pred inv10_correct_6[] {
(all t: (one Trash) {
((t.link) in Trash)
})
}

pred inv10_correct_7[] {
(let x = (File & Trash) {
((x.link) in Trash)
})
}

pred inv10_correct_8[] {
(all f: (one File) {
(all l: (one (f.link)) {
((f in Trash) => (l in Trash))
})
})
}

pred inv10_correct_9[] {
(all t: (one Trash),f: (one File) {
(((t->f) in link) => (f in Trash))
})
}

pred inv10_correct_10[] {
(all x: (one Trash),y: (one File) {
(((x->y) in link) => (y in Trash))
})
}

pred inv10_correct_11[] {
(all x,y: (one File) {
((((x->y) in link) && (x in Trash)) => (y in Trash))
})
}

pred inv10_correct_12[] {
(all f: (one Trash),g: (one File) {
(((f->g) in link) => (g in Trash))
})
}

pred inv10_correct_13[] {
(all f: (one File) {
(((some (f.link)) && (f in Trash)) => ((f.link) in Trash))
})
}

pred inv10_correct_14[] {
(((File & Trash).link) in Trash)
}

pred inv10_correct_15[] {
(all f: (one File),l: (one (f.link)) {
((f in Trash) => (l in Trash))
})
}

pred inv10_correct_16[] {
(all f1,f2: (one File) {
((((f1->f2) in link) && (f1 in Trash)) => (f2 in Trash))
})
}

pred inv10_correct_17[] {
(all l,f: (one File) {
((((l->f) in link) && (l in Trash)) => (f in Trash))
})
}

pred inv10_correct_18[] {
(all w,f: (one File) {
((((w->f) in link) && (w in Trash)) => (f in Trash))
})
}

