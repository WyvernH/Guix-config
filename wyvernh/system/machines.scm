(define-module (wyvernh system machines)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (%wyvernh-base-operating-system
            %wyvernh-base-services
            %wyvernh-user-accounts
            %wyvernh-channels
            %wyvernh-groups))

(define matthew-group
  (user-group
   (name "matthew")
   (id 1000)))

(define plugdev-group
  (user-group
   (name "plugdev")
   (system? #t)))

(define %wyvernh-matthew-account
  (user-account
   (name "matthew")
   (comment "Matthew Hinton")
   (uid 1000)
   (group "matthew")
   (shell (file-append zsh "/bin/zsh"))
   (supplementary-groups
    '("audio"
      "input"
      "kvm"
      "netdev"
      "plugdev"
      "users"
      "video"
      "wheel"))
   (home-directory "/home/matthew")))

(define %wyvernh-user-accounts
  (cons* %wyvernh-matthew-account
         %base-user-accounts))

(define %wyvernh-channels
  (cons* (channel
          (name 'Guix-config)
          (url "https://github.com/WyvernH/Guix-config"))
         (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
         %default-channels))

(define %wyvernh-groups
  (cons* matthew-group plugdev-group %base-groups))

(define %wyvernh-base-services
  (append
   (modify-services %base-services
                    (delete login-service-type)
                    (delete mingetty-service-type)
                    (delete console-font-service-type)
                    (guix-service-type
                     config => (guix-configuration
                                (inherit config)
                                (channels %plt-channels)
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
                                         %default-authorized-guix-keys)))))
  (list
   ;; Seat management (can't use seatd because Wireplumber depends on elogind)
   (service elogind-service-type))))

(define %wyvernh-base-operating-system
  (operating-system
   (host-name "base")
   (timezone "America/Vancouver")
   (locale "en_CA.utf8")
   (locale-definitions
    (list
     (locale-definition (name "en_CA.utf8") (source "en_CA") (charset "UTF-8"))
     (locale-definition (name "en_US.utf8") (source "en_US") (charset "UTF-8"))))
   (kernel linux)
   (initrd microcode-initrd)
   (kernel-arguments '("modprobe.blacklist=nouveau"
                       "nvidia_drm.modeset=1"))
   (firmware
    (list
     linux-firmware))
   (bootloader
    (bootloader-configuration
     (bootloader grub-efi-bootloader)
     (targets (list "/efi"))))
   (file-systems
    (cons*
     %base-file-systems))
   (users %wyvernh-user-accounts)
   (groups %wyvernh-groups)
   (keyboard-layout (keyboard-layout "us"))
   (packages
    (cons* bluez
           bluez-alsa
           brightnessctl
           emacs-no-x-toolkit
           exfat-utils
           fuse-exfat
           git
           gvfs    ;; Enable user mounts
           intel-media-driver/nonfree
           libva-utils
           ntfs-3g
           stow
           vim
           %base-packages))
   (services %wyvernh-base-services)
   ;; Allow resolution of '.local' host names with mDNS.
   (name-service-switch %mdns-host-lookup-nss)))
