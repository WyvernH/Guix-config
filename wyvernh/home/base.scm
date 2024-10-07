(define-module (wyvernh home base)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu home services))

(define (wyvernh-base-packages-service _)
  (list
   gcc-toolchain
   glibc-locales
   htop
   password-store
   tree))

(define-public wyvernh-base-service-type
  (service-type
   (name 'wyvernh-base-service)
   (extensions
    (list (service-extension home-profile-service-type
                             wyvernh-base-packages-service)))
   (default-value #f)
   (description "Install base programs.")))
