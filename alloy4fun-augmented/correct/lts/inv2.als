module alloy4fun_augmented_lts_inv2
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv2_oracle[] {
one Init
}

pred inv2_correct_0[] {
one i : Init { }
}

pred inv2_correct_1[] {
one s : Init | s in State
}

pred inv2_correct_2[] {
always one Init
}

pred inv2_correct_3[] {
one s:State | s in Init
}

pred inv2_correct_4[] {
#Init = 1
}

pred inv2_correct_5[] {
one Init { }
}

