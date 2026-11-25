import AdaptiveRoleSupport

namespace AdaptiveHomogeneousRows
open AdaptiveRoleSupport

-- If an owner's row meets the selected class, the whole row lies in it.
def uniform (field : BinaryRel α β) (selected : Rel β) : Prop :=
  qAll (unaryRightJoin field selected) (fun u => subset (field u) selected)

theorem witnesses (field : BinaryRel α β) (selected : Rel β) :
    uniform field selected ↔
    ∀ u p, selected p → field u p → ∀ q, field u q → selected q := by
  exact ⟨fun h u p hs hp => h u ⟨p,hp,hs⟩, fun h u ⟨p,hp,hs⟩ => h u p hs hp⟩

theorem no_mixed_row (field : BinaryRel α β) (selected : Rel β) :
    uniform field selected ↔
    ¬∃ u p q, field u p ∧ selected p ∧ field u q ∧ ¬selected q := by
  rw [witnesses]
  constructor
  · rintro h ⟨u,p,q,hp,hs,hq,hn⟩
    exact hn (h u p hs hp q hq)
  · intro h u p hs hp q hq
    exact Classical.byContradiction (fun hn => h ⟨u,p,q,hp,hs,hq,hn⟩)

theorem selected_image (field : BinaryRel α β) (selected : Rel β) :
    subset (unaryLeftJoin (unaryRightJoin field selected) field) selected ↔
      uniform field selected :=
  AdaptiveRelationalImage.image_subset_iff_all_fibers _ _ _

-- The colored vertices are targets; the other vertices are owners.
def policy (w : World α β) := uniform (converseBinary w.edge) (fun p => w.role p = true)
def fork : World Bool Unit := ⟨id,fun _ _ => True⟩
def separated : World Bool Bool := ⟨id,fun p u => p = u⟩

theorem sandwich (lo hi : Query) (lb : holds fork lo [] []) (ub : ¬holds separated hi [] [])
    (w : World α β) (violation : Prop)
    (under : holds w lo [] [] → violation) (over : violation → holds w hi [] []) :
    ¬violation ↔ policy w := by
  classical
  constructor
  · intro hv u ⟨p,hp,rp⟩ q hq
    cases rq : w.role q with
    | true => rfl
    | false =>
      let f : Bool → α := fun b => if b then p else q
      let m : Transport fork w :=
        ⟨f,fun _ => u,by intro b; cases b <;> simp [f,fork,rp,rq],
         by intro b _ _; cases b <;> first | exact hq | exact hp⟩
      exact False.elim (hv (under (positive_transport m lo [] [] lb)))
  · intro h hv
    let mark (u : β) := decide (∃ p, w.edge p u ∧ w.role p = true)
    let m : Transport w separated :=
      ⟨w.role,mark,fun _ => rfl,by
        intro p u he
        change w.role p = mark u
        by_cases e : ∃ q, w.edge q u ∧ w.role q = true
        · simpa [mark,e] using h u e p he
        · cases c : w.role p with
          | false => simp [mark,e]
          | true => exact False.elim (e ⟨p,he,c⟩)⟩
    exact ub (positive_transport m hi [] [] (over hv))

def accepts (lo hi : Query) :=
  evaluate [false,true] [()] id (fun _ _ => true) lo [] [] &&
    !evaluate [false,true] [false,true] id (· == ·) hi [] []

theorem accepted_sound (lo hi : Query) (h : accepts lo hi = true) (w : World α β)
    (v : Prop) (lower : holds w lo [] [] → v) (upper : v → holds w hi [] []) :
    ¬v ↔ policy w := by
  rcases Bool.and_eq_true_iff.mp h with ⟨lb,ub⟩
  apply sandwich lo hi _ _ w v lower upper
  · have spec := evaluate_spec [false,true] [()] (fun b => by cases b <;> simp) (by simp)
        id (fun _ _ => true) lo [] []
    simpa [fork] using spec.mp lb
  · intro hg
    have spec := evaluate_spec [false,true] [false,true] (fun b => by cases b <;> simp)
      (fun b => by cases b <;> simp) id (· == ·) hi [] []
    have ht := spec.mpr (by simpa [separated] using hg)
    simp [ht] at ub

private def coloredEdge (color : Bool) : Query :=
  .owner (.conj (.role color 0) (.edge 0 0))

-- Sharing the target-sort binder means sharing the actual posting user.
theorem template_controls :
    let same := Query.target (.conj (coloredEdge true) (coloredEdge false))
    let apart := Query.conj (.target (coloredEdge true)) (.target (coloredEdge false))
    accepts same same = true ∧ accepts apart apart = false := by decide

theorem separate_owners :
    uniform (fun u p : Bool => u = p) (fun p => p = true) ∧
    ¬ subset (unaryLeftJoin univRel (fun u p : Bool => u = p)) (fun p => p = true) := by
  constructor
  · rintro u ⟨p,hp,hs⟩ q hq
    exact hq.symm.trans (hp.trans hs)
  · intro h
    exact Bool.noConfusion (h false ⟨false,trivial,rfl⟩)

theorem separate_instants :
    (∀ t : Bool, uniform (fun (_ : Unit) p => p = t) (fun p => p = true)) ∧
    ¬ qAll (unaryRightJoin (fun (_ : Unit) p => p = true) (fun p => p = true))
      (fun _ => subset (fun p => p = false) (fun p => p = true)) := by
  constructor
  · rintro t u ⟨p,hp,hs⟩ q hq
    exact hq.trans (hp.symm.trans hs)
  · intro h
    exact Bool.noConfusion (h () ⟨true,rfl,rfl⟩ false rfl)

end AdaptiveHomogeneousRows
