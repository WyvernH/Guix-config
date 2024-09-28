(define-module (wyvernh home wayland)
  #:use-module (gnu home services)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services))

(define (wyvernh-wayland-environment-service _)
  '(("QT_QPA_PLATFORM" . "wayland")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("SDL_VIDEODRIVER" . "wayland")
    ("XDG_SESSION_TYPE" . "wayland")))

(define (wyvernh-wayland-packages-service _)
  (list
   xorg-server-xwayland))

(define-public wyvernh-wayland-service-type
  (service-type
   (name 'wyvernh-wayland-service)
   (extensions
    (list (service-extension home-profile-service-type
                             wyvernh-wayland-packages-service)
          (service-extension home-environment-variables-service-type
                             wyvernh-wayland-environment-service)))
   (default-value #f)
   (description "Configure wayland.")))
