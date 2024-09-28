(define-module (wyvernh system install)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu services base)
  #:use-module (gnu services)
  #:use-module (gnu system install)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system)
  #:use-module (guix)
  #:use-module (nongnu packages linux)
  #:use-module (wyvernh system machines)
  #:export (wyvernh-system-install))

(define wyvernh-system-install
  (operating-system
   (inherit installation-os)
   (kernel linux)
   (firmware (list linux-firmware))
   (keyboard-layout (keyboard-layout "us"))
   (services
    (modify-services
     (operating-system-user-services installation-os)
     (guix-service-type
      config => (guix-configuration
                 (inherit config)
                 (channels %wyvernh-channels)
                 (guix (guix-for-channels %wyvernh-channels))
                 (substitute-urls
                  (append (list "https://substitutes.nonguix.org")
                          %default-substitute-urls))
                 (authorized-keys
                  (append (list
                           (plain-file "non-guix.pub"
                                       "\
(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                          %default-authorized-guix-keys))))))))

wyvernh-system-install
