(define-module (wyvernh system machines)
  #:use-module (wyvernh services kmonad)
  #:use-module (gnu)
  #:use-module (guix utils)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages version-control)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (guix channels)
  #:export (%wyvernh-base-operating-system
            %wyvernh-channels
            %wyvernh-base-services
            %wyvernh-matthew-account
            %wyvernh-user-accounts))

(define matthew-group
  (user-group
   (name "matthew")
   (id 1000)))

(define plugdev-group
  (user-group
   (name "plugdev")
   (system? #t)))

(define uinput-group
  (user-group
   (name "uinput")
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
  (cons* matthew-group plugdev-group uinput-group %base-groups))

(define %wyvernh-base-services
  (cons*
   (kmonad-service "/home/matthew/.config/kmonad/config.kbd")
   (modify-services %desktop-services
		    (delete gdm-service-type)
                    (guix-service-type
                     config => (guix-configuration
                                (inherit config)
                                (channels %wyvernh-channels)
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
                                         %default-authorized-guix-keys))))
                    (udev-service-type
                     config => (udev-configuration
                                (inherit config)
                                (rules (cons kmonad
                                             (udev-configuration-rules config))))))))

(define %wyvernh-base-operating-system
  (operating-system
   (host-name "baywyvernh")
   (timezone "America/Vancouver")
   (locale "en_CA.utf8")
   (kernel linux)
   (initrd microcode-initrd)
   (kernel-arguments '("modprobe.blacklist=nouveau"
                       "nvidia_drm.modeset=1"))
   (firmware
    (list
     linux-firmware))
   (keyboard-layout (keyboard-layout "us"))
   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/efi"))
                (keyboard-layout keyboard-layout)))
   (file-systems
    (cons*
     %base-file-systems))
   (users %wyvernh-user-accounts)
   (groups %wyvernh-groups)
   (packages
    (cons* bluez
           bluez-alsa
           brightnessctl
           emacs-no-x-toolkit
           git
           kmonad
           ntfs-3g
           stow
           %base-packages))
   (services %wyvernh-base-services)
   ;; Allow resolution of '.local' host names with mDNS.
   (name-service-switch %mdns-host-lookup-nss)))
