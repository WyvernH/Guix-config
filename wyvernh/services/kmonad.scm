(define-module (wyvernh services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:export (kmonad-service-type))

(define %kmonad-daemon-accounts
  (list (user-account
         (name "kmonad-daemon")
         (group "kmonad-daemon")
         (system? #t)
         (comment "kmonad daemon user")
         (home-directory "/var/empty")
         (shell (file-append shadow "/sbin/nologin")))
        (user-group
         (name "kmonad-daemon")
         (system? #t))))

(define (kmonad-shepherd-service kbd-path)
  (shepherd-service
   (documentation "Run the kmonad daemon (kmonad-daemon)." )
   (provision '(kmonad-daemon))
   (requirement '(udev user-processes))
   (start #~(make-forkexec-constructor
             (list #$(file-append kmonad "/bin/kmonad")
                   #$kbd-path "-l info")
             #:user "kmonad-daemon" #:group "kmonad-daemon"
             #:log-file "/var/log/kmonad.log"))
   (stop #~(make-kill-destructor))))

(define kmonad-service-type
  (service-type
   (name 'kmonad)
   (description
    "Run kmonad as a daemon.")
   (extensions
    (list (service-extension account-service-type
                             (const %kmonad-daemon-accounts))
          (service-extension shepherd-root-service-type
                             (compose list kmonad-shepherd-service))))))
