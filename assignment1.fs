(* Assignment 1 *) (* Do not edit this line. *)
(* Student name: Arjun B. Gupta, Id Number: 260623737 *) (* Edit this line. *)

(* In the template below we have written the names of the functions that
you need to define.  You MUST use these names.  If you introduce auxiliary
functions you can name them as you like except that your names should not
clash with any of the names we are using.  We have also shown the types
that you should have.  Your code must compile and must not go into infinite
loops.  *)

(* Question 1 *) (* Do not edit this line. *)

(* val sumlist : l:float list -> float *)
let rec sumlist l = 
    match l with
    | [] -> 0.0
    | head::tail -> head + sumlist tail

(* val squarelist : l:float list -> float list *)
let rec squarelist (l: float list) =
    match l with
    | [] -> []
    | head::tail -> head*head::(squarelist tail)

(* val mean : l:float list -> float *)
let mean l = (sumlist l)/float(List.length l)

(* val mean_diffs : l:float list -> float list *)
let rec mean_diffs l =
    let rec helper (l,mean_value) =
        match l with
        | [] -> []
        | head::tail -> (head-mean_value)::helper(tail,mean_value)
    helper(l,mean l)
        

(* val variance : l:float list -> float *)
let variance l = l |> mean_diffs |> squarelist |> mean

(* End of question 1 *) (* Do not edit this line. *)

(* Question 2 *) (* Do not edit this line. *)

(* val memberof : 'a * 'a list -> bool when 'a : equality *)
let rec memberof l =
    match l with
    | (a,[]) -> false
    | (a,x::xs) ->
    if (x=a) then true
    else memberof (a,xs)


(* val remove : 'a * 'a list -> 'a list when 'a : equality *)
let remove l =
    let rec helper (l,acc) =
        match l with
        | (a,[]) -> acc
        | (a,x::xs) ->
        if (x=a) then helper ((a,xs),acc)
        else helper ((a,xs),acc @ [x])
    helper (l,[])

(* End of question 2 *) (* Do not edit this line *)

(* Question 3 *) (* Do not edit this line *)

(* val isolate : l:'a list -> 'a list when 'a : equality *)
let rec isolate l = 
    match l with
    | [] -> []
    | x::xs ->
    if memberof (x,xs) then x::isolate (remove (x,xs))
    else x::isolate xs

(* End of question 3 *) (* Do not edit this line *)

(* Question 4 *) (* Do not edit this line *)

(* val common : 'a list * 'a list -> 'a list when 'a : equality *)
let rec common l =
    match l with
    | ([],l1) -> []
    | (x::xs,l1) ->
    if (memberof (x,l1)) then isolate (x::(common (xs,l1)))
    else common (xs,l1)

(* End of question 4 *) (* Do not edit this line *)

(* Question 5 *) (* Do not edit this line *)

(* val split : l:'a list -> 'a list * 'a list *)
let split l =
    let rec helper l (acc1,acc2) =
        match l with
        | [] -> (acc1,acc2)
        | x::xs -> helper xs (acc2,acc1 @ [x])
    helper l ([],[])

(* val merge : 'a list * 'a list -> 'a list when 'a : comparison *)
let rec merge l = 
    match l with
    | (l1,[]) -> l1
    | ([],l2) -> l2
    | (x::xs,y::ys) ->
    if (x < y) then x::(merge (xs,y::ys))
    else y::(merge (x::xs,ys))

(* val mergesort : l:'a list -> 'a list when 'a : comparison *)
let rec mergesort l =
    match l with
    | [] -> []
    | [x] -> [x]
    | x::xs ->
    let (l1,l2) = split (x::xs)
    merge (mergesort l1, mergesort l2)

(* End of question 5 *) (* Do not edit this line *)

