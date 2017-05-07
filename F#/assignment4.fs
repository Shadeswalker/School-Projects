module hw4

(* Assignment 4 *) (* Do not edit this line. *)
(* Student name: Arjun B. Gupta, Id Number: 260623737 *) (* Edit this line. *)


type typExp =
  | TypInt
  | TypVar of char
  | Arrow of typExp * typExp
  | Lst of typExp

type substitution = (char * typExp) list

(* check if a variable occurs in a term *)
let rec occurCheck (v: char) (tau: typExp) : bool = 
    match tau with
    | TypInt -> false
    | TypVar c -> if (c = v) then true
                  else false
    | Arrow (a,b) -> if (occurCheck v a) then true
                     else (occurCheck v b)
    | Lst a -> occurCheck v a

(* substitute typExp tau1 for all occurrences of type variable v in typExp tau2 *)
let rec substitute (tau1 : typExp) (v : char) (tau2 : typExp) : typExp =
    match tau2 with
    | TypInt -> tau2
    | TypVar c -> if (v=c) then tau1
                  else tau2
    | Arrow (a,b) -> Arrow ((substitute tau1 v a),(substitute tau1 v b))
    | Lst a -> Lst (substitute tau1 v a)

let applySubst (sigma: substitution) (tau: typExp) : typExp =
    List.fold (fun tau (c, tau1) -> substitute tau1 c tau ) tau sigma


let rec unify (tau1: typExp) (tau2:typExp) : substitution =
    match tau1 with
    | TypInt ->
        match tau2 with
        | TypInt -> []
        | TypVar a -> [(a,TypInt)]
        | Arrow (exp1,exp2) -> failwith "Not unifiable"
        | Lst a -> failwith "Not unifiable"
    | TypVar a -> 
        match tau2 with
        | TypVar b -> if (a=b) then []
                      else [(a,tau2)]
        | TypInt | Arrow _| Lst _ -> if (occurCheck a tau2) then failwith "Failed occurs check"
                                     else [(a,tau2)]
    | Arrow (exp1,exp2) ->
        match tau2 with
        | TypInt -> failwith "Not unifiable"
        | TypVar a -> if (occurCheck a tau1) then failwith "Failed occurs check"
                      else [(a,tau1)]
        | Arrow (exp3,exp4) ->
            let subs = (unify exp1 exp3)
            subs@(unify (applySubst subs exp2) (applySubst subs exp4))
        | Lst a -> failwith "Clash in principal type constructor"
    | Lst exp1 ->
        match tau2 with
        | TypInt -> failwith "Not unifiable"
        | TypVar a -> if (occurCheck a tau1) then failwith "Failed occurs check"
                      else [(a,tau1)]
        | Arrow (exp2,exp3) -> failwith "Clash in principal type constructor"
        | Lst exp2 -> unify exp1 exp2


(*

> let te4 = Arrow(TypInt, Arrow(TypVar 'c', TypVar 'a'));;

val te4 : typExp = Arrow (TypInt,Arrow (TypVar 'c',TypVar 'a'))

> let te3 = Arrow (TypVar 'a',Arrow (TypVar 'b',TypVar 'c'));;

val te3 : typExp = Arrow (TypVar 'a',Arrow (TypVar 'b',TypVar 'c'))

> unify te3 te4;;
val it : substitution = [('c', TypInt); ('b', TypVar 'c'); ('a', TypInt)]
> let result = it;;

val result : substitution = [('c', TypInt); ('b', TypVar 'c'); ('a', TypInt)]

> applySubst result te3;;
val it : typExp = Arrow (TypInt,Arrow (TypInt,TypInt))
> applySubst result te4;;
val it : typExp = Arrow (TypInt,Arrow (TypInt,TypInt))

*)