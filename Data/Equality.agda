module OTT.Data.Equality where

open import OTT.Main

infix 3 _≡_

_≡_ : ∀ {A} -> ⟦ A ⟧ -> ⟦ A ⟧ -> Type
x ≡ y = mu (var x) y

pattern preflₑ q = node q

prefl : ∀ {A} {x : ⟦ A ⟧} -> ⟦ x ≡ x ⟧
prefl {x = x} = preflₑ (refl x)

Jₕₑ : ∀ {π A} {x y : ⟦ A ⟧}
    -> (P : ∀ {y} -> ⟦ x ≡ y ⟧ -> Set π)
    -> ({y : ⟦ A ⟧} -> (q : ⟦ x ≅ y ⟧) -> P (preflₑ q))
    -> (q : ⟦ x ≡ y ⟧)
    -> P q
Jₕₑ P z (preflₑ q) = z q

Jₕ : ∀ {k A} {x y : ⟦ A ⟧}
   -> (P : ∀ {y} -> ⟦ x ≡ y ⟧ -> Univ k)
   -> ⟦ P prefl ⟧
   -> (q : ⟦ x ≡ y ⟧)
   -> ⟦ P q ⟧
Jₕ P z = Jₕₑ (⟦_⟧ ∘ P) (J (λ y -> P {y} ∘ preflₑ) z)
