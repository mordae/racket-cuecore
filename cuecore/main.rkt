#lang typed/racket/base
;
; CueCore Lighting Control
;

(require racket/match
         typed/racket/class
         typed/net/url
         typed/json)

(require mordae/syntax
         mordae/match)

(provide Group
         group?
         CueCore%
         cuecore%)


(define-type Group
  (U 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))

(define-predicate group? Group)


(define-logger cuecore)


; Relevant CueCore Endpoints
; ==========================
;
; > /ajax/monitor/status
; {
;   "source": "source-dmx-outa",
;   "page": 0,
;   "unit": "unit-decimal"
; }
;
; > /ajax/monitor/channels
; {
;   "channels": {
;     "first": 1,
;     "data": [255,0,... 0]
;   }
; }
;
; > /ajax/monitor/input/page-up
; > /ajax/monitor/input/page-down
; > /ajax/monitor/input/unit-decimal
; > /ajax/monitor/input/unit-percentage
; > /ajax/monitor/input/source-dmx-outa
; > /ajax/monitor/input/source-dmx-outb
; > /ajax/console/input/command/{channel}@{value}
; "ok": 1
;
; Invalid requests cause a "200 OK" response that is indistinguishable
; from responses to valid commands. Therefore, no error detection.


(define-type CueCore%
  (Class
    (init-field (host String))
    (set-channel! (-> Natural Natural Void))
    (get-status (-> Group (Listof Natural)))))


(: cuecore% CueCore%)
(define cuecore%
  (class object%
    (init-field host)

    (: request (-> String Any * JSExpr))
    (define/private (request fmt . args)
      (define in-port : Input-Port
        (get-pure-port
          (string->url
            (let ((path (apply format fmt args)))
              (format "http://~a~a" host path)))))

      (begin0
        (if (regexp-match-peek #"^{" in-port)
            (let ((js (read-json in-port)))
              (if (eof-object? js) 'null js))
            (values 'null))
        (close-input-port in-port)))

    (define/public (set-channel! channel value)
      (void
        (request "/ajax/monitor/input/unit-decimal")
        (request "/ajax/console/input/command/~a@~a" channel value)))

    (define/public (get-status group)
      (request "/ajax/monitor/input/unit-decimal")

      (if (< group 8)
          (request "/ajax/monitor/input/source-dmx-outa")
          (request "/ajax/monitor/input/source-dmx-outb"))

      (let loop ()
        (match (request "/ajax/monitor/status")
          ((hash-lookup ('page (? integer? page)))
           (unless (= page (modulo group 8))
             (request "/ajax/monitor/input/page-down")
             (loop)))))

      (match (request "/ajax/monitor/channels")
        ((hash-lookup ('channels (hash-lookup ('data (? list? data)))))
         (cast data (Listof Natural)))))

    (super-new)))


; vim:set ts=2 sw=2 et:
