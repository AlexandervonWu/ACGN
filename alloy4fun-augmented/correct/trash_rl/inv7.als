module alloy4fun_augmented_trash_rl_inv7
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv7_oracle[] {
(no (link.Trash))
}

pred inv7_correct_0[] {
(all f: (one File) {
(no (Trash & (f.link)))
})
}

pred inv7_correct_1[] {
(all file: (one File) {
(((file.link) & Trash) = none)
})
}

pred inv7_correct_2[] {
(all t: (one Trash) {
(no (link.t))
})
}

pred inv7_correct_3[] {
(all f: (one (File.link)) {
(f !in Trash)
})
}

pred inv7_correct_4[] {
(no ((File.link) & Trash))
}

pred inv7_correct_5[] {
(all f: (one Trash) {
(no (link.f))
})
}

pred inv7_correct_6[] {
(all f: (one File) {
((f.link) in (File - Trash))
})
}

pred inv7_correct_7[] {
(all f,l: (one File) {
(((f->l) in link) => (l !in Trash))
})
}

pred inv7_correct_8[] {
(no (link.Trash))
}

pred inv7_correct_9[] {
(all l: (one (File.link)) {
(l !in Trash)
})
}

pred inv7_correct_10[] {
(all f,f1: (one File) {
(((f->f1) in link) => (f1 !in Trash))
})
}

pred inv7_correct_11[] {
(no (link :> Trash))
}

pred inv7_correct_12[] {
(all f: (one File) {
(all l: (one (f.link)) {
(l !in Trash)
})
})
}

pred inv7_correct_13[] {
(all f: (one File) {
(no ((f.link) & Trash))
})
}

pred inv7_correct_14[] {
(all f: (one File),l: (one (f.link)) {
(l !in Trash)
})
}

pred inv7_correct_15[] {
(((File.link) & Trash) = none)
}

pred inv7_correct_16[] {
(Trash in (Trash - (File.link)))
}

pred inv7_correct_17[] {
(all f1,f2: (one File) {
(((f1->f2) in link) => (f2 !in Trash))
})
}

pred inv7_correct_18[] {
(all x: (one File),y: (one File) {
(((x->y) in link) => (y !in Trash))
})
}

pred inv7_correct_19[] {
(all f1,f2: (one File) {
(((f1->f2) in link) => (!(f2 in Trash)))
})
}

pred inv7_correct_20[] {
(all f: (one File) {
((some (link.f)) => (f !in Trash))
})
}

pred inv7_correct_21[] {
(all f: (one File) {
(no (link.Trash))
})
}

