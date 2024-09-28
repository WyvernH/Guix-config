(define-module (wyvernh home configs baywyvernh)
  #:use-module (gnu home)
  #:use-module (gnu services)
  #:use-module (wyvernh home services)
  #:use-module (wyvernh home sway)
  #:use-module (wyvernh home waybar)
  #:export (wyvernh-home-environment))

(define wyvernh-home-environment
  (home-environment
   (services
    (modify-services
     %wyvernh-home-services
     (wyvernh-sway-service-type
      config => (wyvernh-sway-configuration
                 (machine "baywyvernh")))
     (wyvernh-waybar-service-type
      config => (wyvernh-waybar-configuration
                 (machine "baywyvernh")
                 (font-size "20px")))))))

wyvernh-home-environment
