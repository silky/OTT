module OTT.Data.W where

open import OTT.Main

w : (A : Type) -> (⟦ A ⟧ -> Type) -> Type
w A B = mu (π A λ x -> (B x ⇨ var tr) ⊛ var tr) tr

W : (A : Type) -> (⟦ A ⟧ -> Type) -> Set
W A B = ⟦ w A B ⟧

pattern sup x g = node (x , g , tt)

{-# TERMINATING #-}
elimW : ∀ {π A} {B : ⟦ A ⟧ -> Type}
      -> (P : W A B -> Set π)
      -> (∀ {x} {g : ⟦ B x ⟧ -> W A B} -> (∀ y -> P (g y)) -> P (sup x g))
      -> ∀ w
      -> P w
elimW P h (sup x g) = h (λ y -> elimW P h (g y))
