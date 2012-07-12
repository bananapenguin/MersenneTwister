(load 'logical.scm)
(define mt_N 624)
(define mt_M 397)
(define mt_MATRIX_A #x9908b0df)
(define mt_UPPER_MASK #x80000000)
(define mt_LOWER_MASK #x7fffffff)
(define mt_i (+ mt_N 1))
(define mt (make-vector mt_N))
(define mag01 (vector 0 mt_MATRIX_A))

(define mt_init_genrand
  (lambda (s)
	(vector-set! mt 0 (logand s #xffffffff))
	(let loop ((n1 1))
	  (set! mt_i n1)
	  (if (< n1 mt_N)
		(let ()
		(vector-set! mt mt_i 
					 (+ mt_i 
						(* 1812433253 
						   (logxor (vector-ref mt (- mt_i 1))
								(ash (vector-ref mt (- mt_i 1)) -30)))))
		(vector-set! mt mt_i (logand (vector-ref mt mt_i) #xffffffff))
		(loop (+ n1 1)))))
	 s))

(define mt_genrand_int32
  (lambda ()
	(let ((y))
	(if (>= mt_i mt_N)
	  (let ((kk 0))
		(if (eq? mt_i (+ mt_N 1))
		  (mt_init_genrand 5489))

		(let loop ()
		  (if (< kk (- mt_N mt_M))
			(begin
			  (set! y (logior (logand (vector-ref mt kk) mt_UPPER_MASK) 
							  (logand (vector-ref mt (+ kk 1)) mt_LOWER_MASK)))
			  (vector-set! mt kk (logxor (vector-ref mt (+ kk mt_M))
										 (logxor (ash y -1) (vector-ref mag01 (logand y 1)))))
			  (set! kk (+ kk 1))
			  (loop))))

		(let loop ()
		  (if (< kk (- mt_N 1))
			(begin
			  (set! y (logior (logand (vector-ref mt kk) mt_UPPER_MASK) 
							  (logand (vector-ref mt (+ kk 1)) mt_LOWER_MASK)))
			  (vector-set! mt kk (logxor (vector-ref mt (+ kk (- mt_M mt_N)))
										 (logxor (ash y -1) (vector-ref mag01 (logand y 1)))))
			  (set! kk (+ kk 1))
			  (loop))))

		(set! y (logior (logand (vector-ref mt (- mt_N 1)) mt_UPPER_MASK)
						(logand (vector-ref mt 0) mt_LOWER_MASK)))
		(vector-set! mt (- mt_N 1) (logxor (vector-ref mt (- mt_M 1))
										   (logxor (ash y -1) (vector-ref mag01 (logand y 1)))))
		(set! mt_i 0)
		))

	(set! y (vector-ref mt mt_i))
	(set! mt_i (+ mt_i 1))
	(set! y (logxor y (ash y -11)))
	(set! y (logxor y (logand (ash y 7) #x9d2c5680)))
	(set! y (logxor y (logand (ash y 15) #xefc60000)))
	(set! y (logxor y (ash y -18)))
	y)))

(define genrand_real
  (lambda ()
	(/ (mt_genrand_int32) 4294967296.0)))
