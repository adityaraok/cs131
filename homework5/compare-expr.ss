;; function compares if two arguments are lists
;; written to make the comapare-expr more readable
(define (arelists x y)
    (and (list? x) (list? y) (not(equal? x '())) (not(equal? y '())) )
)
;; funciton which takes in two arguments
;; and spits out this format: if TCP arg1 arg2
(define (iftcpformat c d)
  (cons 'if (cons 'TCP (cons c (cons d '()))))
)
;; helper functions
;; most of the funciton names are self explanatory
(define (emptylists x y)
  ;(print "emptylists")
    (or
      (equal? x '())
      (equal? y '())
    )
)

(define (isquote x)
  (equal? (car x) 'quote)
)

(define (islambda x)
  (equal? (car x) 'lambda)
)

(define (islet x)
  (equal? (car x) 'let)
)

(define (isif x)
  (equal? (car x) 'if)
)

;; this function is called when there is no let, quote,lambda,if in x and y.
;; 
(define (compare-expr-plain x y)
  ;(print "compare-expr-plain")
    (cond
      ((equal? x y) x)
      ( (and (equal? x #f) (equal? y #t) ) '(not TCP) )
      ((and (equal? x #t)(equal? y #f)) 'TCP )
      (else (iftcpformat x y))
    )
)

;; this function recursively takes each element of a list and applies the match-function to 
;; each individual element.
(define (accumulate-list x y)
   ;(print "accumulate-list")
  (cond
    ( (or (equal? x '()) (equal? y '())) '() )
    (else (cons (compare-expr (car x) (car y) ) (accumulate-list (cdr x) (cdr y) )) )
  )
)

;; this funciton is to parse x and y if different functions are found on either side
;; the the specs such cases are to be considered as x and y are completely different
(define (parse-diff-functions x y)
  ;(print "parse-diff-functions")
  (cond
    ((or (isquote x) (isquote y) (islambda x) (islambda y) (islet x) (islet y) (isif x) (isif y) )
      (compare-expr-plain x y))
    (else (accumulate-list x y))

  )
)

;; this function matches the 4 functions with the lists x and y
;; to see if they are present.
(define (match-function x y)
  ;(print "match-function")
    (cond
        ((equal? (car x) 'quote) (compare-expr-plain x y))
        ((equal? (car x) 'lambda) (compare-expr-lambda x y))
        ((equal? (car x) 'let) (compare-expr-let x y)) 
        (#t (accumulate-list x y))
    )
)



;; function to check each element is a list
;; if elements are equal, check for the let,quote,lambda,if else 
;; check if different functions on either side.
(define (check-elements x y)
 ; (print "check-elements")
  (if (equal? (car x) (car y)) (match-function x y) (parse-diff-functions x y))
)

;; function to check the length of the list.
;; if equal calls the function to check each element of the lists
(define (check-length x y)
  ;(print "check-length")
  (if (equal? (length x) (length y)) (check-elements x y) (compare-expr-plain x y))
)

(define (compare-expr x y)
  (if (arelists x y) (check-length x y) (compare-expr-plain x y))
)
;; function to check bindings if let is found on each side
(define (check-binding x y)
  ;(print "check-binding")
      (cond
        ((emptylists x y) #t)
        ( (equal? (car (car x)) (car (car y)) ) (check-binding (cdr x) (cdr y) ))
        (else #f)
      )
)

;; takes the bindings of let and checks them
(define (compare-expr-let x y)
  ;(print "compare-expr-let")
  (cond 
      ((check-binding (car (cdr x)) (car (cdr y))) (accumulate-list x y))
      (else (compare-expr-plain x y))
  )
)
 

;; lambda arguments are cheecked
(define (compare-expr-lambda x y)
      (cond 
        ((equal? (car (cdr x)) (car (cdr y))) (accumulate-list x y))
        (else (compare-expr-plain x y))
      )
)


;;; test cases

(define test-x
     
'(and (lambda (a b c d) (let ((a 1) (b 2) (c 3) (d 4)) 
  ( and (if (= a (* b 2) ) 
  (=(length (cons a(cons b c))) b) (not(= c d))) (if #t #t #f) ) ))
    (cons (if #t 5 6) '()) #f)
)


(define test-y
    '(and (lambda (a b c d) (let ((a 1) (b 3) (c 2) (d 4)) 
        ( and (if (= b (+ c 1)) 
        (=(length (cons b(cons a c))) b) (not(= c d))) (if #f #f #t) )))
        (car(cons (if #f 7 8) '() )) #t
      )
)



(define (eval-compare-expr l tcp)
      (cond
        (tcp (eval(quasiquote(let ((TCP #t)) ,l   ) ))) 
        (else (eval(quasiquote(let ((TCP #f)) ,l   ) ) ))
      )
)


(define (test-compare-expr x y)
      (and 
        (equal? (eval x) (eval-compare-expr (compare-expr x y) #t) )
        (equal? (eval y) (eval-compare-expr (compare-expr x y) #f) )
      )

)
