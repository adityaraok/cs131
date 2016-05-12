(define (iftcpformat c d)
	(cons 'if (cons 'TCP (cons c (cons d '()))))
)


(define (islambda x)
	(cond ( (equal? (car x) 'lambda)  #t)
		  (else #f ) 	
	)
)

(define (compare-expr-lambda x y)
  (cond (equal? (car (cdr x)) (car (cdr y)))
    (compare-expr-list x y '())  
  (else (iftcpformat  x  y )))
)

(define (isquote x)
	(cond 
		((equal? (car x) 'quote)	#t)
		(else #f)
	)
)

(define (compare-expr-plain x y)
	(cond 
		( (not(= (length x) (length y)) )	(iftcpformat x y) )
		( (and (list? x) (list? y) ) (compare-expr-list x y  ))
		(else (append acc (iftcpformat x y)))

	)
)


(define (compare-expr-list x y)
		(cond
			((or (eq? x '() ) (eq? y '() )) '())
			( (and (list? (car x) )(list? (car y)) ) 
				(cons (compare-expr (car x) (car y)) (compare-expr-list (cdr x) (cdr y) ) ) )
			(else  (iftcpformat  x  y ) )

		)
)

(define (compare-expr-list-helper x y)
	(cond
		((and (list? (car x)) (list? (car y) )) 
			(cons (compare-expr (car x) (car y)) (compare-expr-list (cdr x) (cdr y))))
		(else (compare-expr-list  x  y))

	)
)

(define (compare-expr x y)
(cond ((equal? x y) x)
	  ((and (equal? x #t) (equal? y #f)) 'TCP )
	  ((and (equal? x #f) (equal? y #t)) '(not TCP))
	  ((isquote x) (iftcpformat x y) )
	  ((islambda x) (compare-expr-lambda (car x) (car y) ) )
	  (else  (compare-expr-plain x y ))
)
)
















(define (iftcpformat c d)
	(cons 'if (cons 'TCP (cons c (cons d '()))))
)


(define (compare-expr x y)
	(cond
		((equal? x y) x) 
		((and (equal? x #t) (equal? y #f)) 'TCP)
		((and (equal? x #f) (equal? y #t)) '(not TCP))
		((arelists x y) (compare-expr-list x y))
		(else iftcpformat x y)
	)
)


(define (arelists x y)
		(and (list? x) (list? y))
)

(define (isEqualLength x y)
	(equal? (length x) (length y))
)

(define (compare-expr-list x y)
		(cond
			((isEqualLength x y) (compare-expr-list-helper x y))
			(else (iftcpformat x y))
		)
)

(define (compare-expr-list-helper x y)
	(cond
		((equal? (car x) (car y))  (match-symbol x y))
		((and (function-within-list-of-list x) (function-within-list-of-list y)) 
			(cons (match-symbol (car x) (car y)) (accumulate-list (cdr x) (cdr y) ) ) )
		(else (iftcpformat x y))
	)
)

(define (function-within-list-of-list x)
		(list? (car x))
)

(define (match-symbol x y)
	(cond
		((isquote x)(compare-expr-quote x y))
		((islambda x) (compare-expr-lambda x y))
		((islet x) (compare-expr-let x y))
		(else (compare-expr-plain x y))
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

(define (compare-expr-quote x y)
	(cond
		((equal? x y) x)
		(else (iftcpformat x y))
	)
)

(define (compare-expr-lambda x y)
		(cond
			((equal? (car (cdr x) (car (cdr y)))) (accumulate-list x y))   
			(else (compare-expr-plain x y))
		)
)


(define (accumulate-list x y)
	(cond
		((equal? x '()) '())
		((equal? y '()) '())
		(else (cons (compare-expr (car x) (car y)) (accumulate-list (cdr x) (cdr y))))
	)

)

(define (compare-expr-plain x y)
	(compare-expr x y)
)


















(define (compare-expr x y)
  (if (and (list? x) (list? y))
    (if (equal? (length x) (length y))
      (if (equal? (car x) (car y))
        (case (car x)
          ('quote (compare-expr-quote x y))
          ;['if (compare-expr-if x y)]
          ('lambda (compare-expr-lambda x y))
          ('let (compare-expr-let x y))
          (else (compare-expr-list x y)))
        (if (builtin-function-on-either-side x y)
          (compare-expr-constant x y)
          (compare-expr-list x y)))
      ; According to test cases, if x y z, and if x y can be treated as completely different
      (compare-expr-constant x y))
    (compare-expr-constant x y))
)

((lambda (a b) (f (if TCP a c) b)) 1 2)