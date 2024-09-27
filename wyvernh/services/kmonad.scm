(define-module (wyvernh services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix gexp)
  #:export (kmonad-service))

(define (kmonad-shepherd-service config-path)
  ;; Tells shepherd how we want it to create a (single) <shepherd-service>
  ;; for kmonad from a string
  (list (shepherd-service
          (documentation "Run the kmonad daemon (kmonad-daemon).")
          (provision '(kmonad-daemon))
          (requirement '(udev user-processes))
          (start #~(make-forkexec-constructor
                     (list #$(file-append kmonad "/bin/kmonad")
                           #$config-path)))
          (stop #~(make-kill-destructor)))))

(define kmonad-service-type
  ;; Extend the shepherd root into a new type of service that takes a single string
  (service-type
   (name 'kmonad)
   (description
    "Run kmonad as a daemon.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             kmonad-shepherd-service)))))

(define (kmonad-service config-path)
  ;; Create a service from our service type, which takes a single parameter
  (service kmonad-service-type config-path))



;(define-module (wyvernh services kmonad)
;  #:use-module (gnu services)
;  #:use-module (gnu services shepherd)
;  #:use-module (gnu packages admin)
;  #:use-module (gnu packages haskell-apps)
;  #:use-module (gnu system shadow)
;  #:use-module (guix gexp)
;  #:export (kmonad-service-type))

;(define %kmonad-daemon-accounts
;  (list (user-account
;         (name "kmonad-daemon")
;         (group "kmonad-daemon")
;         (system? #t)
;         (comment "kmonad daemon user")
;         (home-directory "/var/empty")
;         (shell (file-append shadow "/sbin/nologin"))
;	 (supplementary-groups '("input" "uinput")))
;        (user-group
;         (name "kmonad-daemon")
;         (system? #t))))

;(define (kmonad-shepherd-service kbd-path)
;  (shepherd-service
;   (documentation "Run the kmonad daemon (kmonad-daemon)." )
;   (provision '(kmonad-daemon))
;   (requirement '(udev user-processes))
;   (start #~(make-forkexec-constructor
;             (list #$(file-append kmonad "/bin/kmonad")
;                   #$kbd-path "-l" "info")
;             #:user "kmonad-daemon" #:group "kmonad-daemon"
;             #:log-file "/var/log/kmonad.log"))
;   (stop #~(make-kill-destructor))))

;(define kmonad-service-type
;  (service-type
;   (name 'kmonad)
;   (description
;    "Run kmonad as a daemon.")
;   (extensions
;    (list (service-extension account-service-type
;                             (const %kmonad-daemon-accounts))
;          (service-extension shepherd-root-service-type
;                             (compose list kmonad-shepherd-service))))))
