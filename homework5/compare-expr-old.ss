(define (iftcpformat c d)
	(cons 'if (cons 'TCP (cons c (cons d '()))))
)

(define (isEqualLength x y)
	(equal? (length x) (length y))
)

(define (arelists x y)
		(and (list? x) (list? y))
)


(define (compare-expr x y)
	(cond
		((equal? x y) x) 
		((and (equal? x #t) (equal? y #f)) 'TCP)
		((and (equal? x #f) (equal? y #t)) '(not TCP))
		((arelists x y) (parse-list x y '()))
		(else (iftcpformat x y))
	)
)

(define (parse-list x y acc)
	(cond
		((not(isEqualLength x y)) (iftcpformat x y))
		((or (equal? x '()) (equal? y'()) ) acc)
		((equal? (car x) (car y)) (parse-list (cdr x) (cdr y) (append acc (list (car x)) ) ) ) 
		;logic here to be implemented for functions

		(else  (parse-list (cdr x) (cdr y) 
			((append acc (function-specific-acc (car x) (car y) ) ) ) ) )
	)
)

(define (function-specific-acc x y)
	(if (and (list? x) (list? y) )
		(cond ((equal? (car x) (car y) ) 
			(case (car x)
				('quote (compare-expr-quote x y))
				('let (compare-expr-let x y))
				('lambda (compare-expr-lambda x y))
			))
			(else (iftcpformat (car x) (car y))))
		(iftcpformat x y)
	)
)


(define (compare-expr-quote x y)
	(cond 
		((equal (cdr x) (cdr y)) ( ) )
		(else (iftcpformat x y))
	)
)