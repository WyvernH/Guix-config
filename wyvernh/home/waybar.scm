(define-module (wyvernh home waybar)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu home services)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 format)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 optargs)
  #:export (wyvernh-waybar-service-type
            wyvernh-waybar-configuration))

;; TODO: Make a proper config
(define-configuration/no-serialization wyvernh-waybar-configuration
  (machine
   (string "baywyvernh")
   "Specify the machine to generate the config for.")
  (font-size
   (string "13px")
   "Font size for waybar"))

(define (wyvernh-waybar-packages-service _)
  (list
   waybar
   waybar-cpu-histogram))

(define-public wyvernh-waybar-service-type
  (service-type
   (name 'wyvernh-waybar-service)
   (extensions
    (list (service-extension home-profile-service-type
                             wyvernh-waybar-packages-service)
          ;(service-extension home-files-service-type
          ;                   wyvernh-waybar-config)
	  ))
   (default-value #f)
   (description "Install and configure waybar.")))
