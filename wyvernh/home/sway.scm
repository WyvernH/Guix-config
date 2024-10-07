(define-module (wyvernh home sway)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages hardware)
  #:use-module (gnu packages image)
  #:use-module (gnu packages music)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (nongnu packages mozilla)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 optargs)
  #:export (wyvernh-sway-service-type
            wyvernh-sway-configuration))

;; TODO: proper config
(define-configuration/no-serialization wyvernh-sway-configuration
  (machine
   (string "baywyvernh")
   "Specify the machine to generate the config for."))

(define (wyvernh-sway-environment _)
  '(("XDG_CURRENT_DESKTOP" . "sway")))

(define (wyvernh-sway-packages-service _)
  (list sway
        swayidle
        swaylock
        emacs-next-pgtk
	kitty
	firefox
	grim
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        wtype
        font-hack
        playerctl))

(define wyvernh-sway-service-type
  (service-type
   (name 'wyvernh-sway-service)
   (extensions
    (list (service-extension home-profile-service-type
                             wyvernh-sway-packages-service)
          ;(service-extension home-files-service-type
          ;                   wyvernh-sway-config)
          (service-extension home-environment-variables-service-type
                             wyvernh-sway-environment)
          ;(service-extension home-shepherd-service-type
          ;                   wyvernh-playerctld-shepherd)
          ;(service-extension home-xdg-configuration-files-service-type
	  ;                   wyvernh-xdg-desktop-portal-wlr-configuration)
	  ))
   (default-value (wyvernh-sway-configuration))
   (description "Install and configure sway.")))
