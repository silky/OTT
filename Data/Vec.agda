module OTT.Data.Vec where

open import OTT.Prelude
open import OTT.Core
open import OTT.Coerce

open import Data.List.Base as List using (List)

infixr 5 _∷_

vec : ∀ {k} -> Univ k -> ℕ -> Type
vec A = mu $ π (fin 2) λ
  {  fzero           -> var 0
  ; (fsuc fzero)     -> π nat λ n -> A ⇨ var n ⊛ var (suc n)
  ; (fsuc (fsuc ()))
  }

Vec : ∀ {k} -> Univ k -> ℕ -> Set
Vec A n = ⟦ vec A n ⟧

pattern vnilₑ      q      = #₀ q
pattern vconsₑ {n} q x xs = #₁ (n , x , xs , q)

[] : ∀ {k} {A : Univ k} -> Vec A 0
[] = vnilₑ (refl 0)

_∷_ : ∀ {n k} {A : Univ k} -> ⟦ A ⇒ vec A n ⇒ vec A (suc n) ⟧
_∷_ {n} = vconsₑ (refl (suc n))

{-# TERMINATING #-}
elimVecₑ : ∀ {n k π} {A : Univ k}
         -> (P : ∀ {n} -> Vec A n -> Set π)
         -> (∀ {n m} {xs : Vec A n}
               -> (q : ⟦ suc n ≅ m ⟧) -> (x : ⟦ A ⟧) -> P xs -> P {m} (vconsₑ q x xs))
         -> (∀ {m} -> (q : ⟦ 0 ≅ m ⟧) -> P {m} (vnilₑ q))
         -> (xs : Vec A n)
         -> P xs
elimVecₑ P f z (vnilₑ  q)      = z q
elimVecₑ P f z (vconsₑ q x xs) = f q x (elimVecₑ P f z xs)
elimVecₑ P f z  ⟨⟩₂

foldVec : ∀ {n k π} {A : Univ k} {P : Set π} -> (⟦ A ⟧ -> P -> P) -> P -> Vec A n -> P
foldVec f z = elimVecₑ _ (const f) (const z)

fromVec : ∀ {n k} {A : Univ k} -> Vec A n -> List ⟦ A ⟧
fromVec = foldVec List._∷_ List.[]

elimVec′ : ∀ {n k π} {A : Univ k}
         -> (P : List ⟦ A ⟧ -> Set π)
         -> (∀ {n} {xs : Vec A n} -> (x : ⟦ A ⟧) -> P (fromVec xs) -> P (x List.∷ fromVec xs))
         -> P List.[]
         -> (xs : Vec A n)
         -> P (fromVec xs)
elimVec′ P f z = elimVecₑ (P ∘ fromVec) (λ {n m xs} _ -> f {xs = xs}) (const z)

elimVec : ∀ {n k s} {A : Univ k}
        -> (P : ∀ {n} -> Vec A n -> Univ s)
        -> (∀ {n} {xs : Vec A n} -> (x : ⟦ A ⟧) -> ⟦ P xs ⇒ P (x ∷ xs) ⟧)
        -> ⟦ P [] ⟧
        -> (xs : Vec A n)
        -> ⟦ P xs ⟧
elimVec P f z = elimVecₑ (⟦_⟧ ∘ P)
  (λ {n m xs} q x r -> J (λ m q -> P {m} (vconsₑ q x xs)) (f x r) q)
  (λ {m}      q     -> J (λ m q -> P {m} (vnilₑ q)) z q)

lookupₑ : ∀ {n m k} {A : Univ k} -> ⟦ n ≅ m ⟧ -> Fin n -> Vec A m -> ⟦ A ⟧
lookupₑ             q₁  fzero   (vconsₑ     q₂ x xs) = x
lookupₑ {suc n} {m} q₁ (fsuc i) (vconsₑ {p} q₂ x xs) = lookupₑ (left (suc n) {m} {suc p} q₁ q₂) i xs
lookupₑ _ _ _ = noway -- Later.

lookup : ∀ {n k} {A : Univ k} -> Fin n -> Vec A n -> ⟦ A ⟧
lookup {n} = lookupₑ (refl n)

cmu : ∀ {n I} -> Vec (desc I) n -> ⟦ I ⟧ -> Type
cmu {n} ds = mu (π (fin n) (flip lookup ds))
