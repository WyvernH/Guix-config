(define-module (wyvernh system machines)
  #:use-module (gnu)
  #:use-module (gnu system nss)
  #:use-module (guix utils)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages emacs)
  #:export (%wyvernh-base-operating-system))

(use-service-modules desktop sddm xorg)
(use-package-modules certs gnome)

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
   ;(shell (file-append zsh "/bin/zsh"))
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

   ;; Use the UEFI variant of GRUB with the EFI System
   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/efi"))
                (keyboard-layout keyboard-layout)))
   (file-systems
    (cons*
     %base-file-systems))

   (users %wyvernh-user-accounts)
   (groups %wyvernh-groups)

   ;; This is where we specify system-wide packages.
   (packages (append (list
                      ;; for user mounts
                      gvfs
                      ;; because
                      emacs)
                     %base-packages))

   ;; Add GNOME and Xfce---we can choose at the log-in screen
   ;; by clicking the gear.  Use the "desktop" services, which
   ;; include the X11 log-in service, networking with
   ;; NetworkManager, and more.
   (services (if (target-x86-64?)
                 (append (list (service gnome-desktop-service-type)
                               (service xfce-desktop-service-type)
                               (set-xorg-configuration
                                (xorg-configuration
                                 (keyboard-layout keyboard-layout))))
                         %desktop-services)

                 ;; FIXME: Since GDM depends on Rust (gdm -> gnome-shell -> gjs
                 ;; -> mozjs -> rust) and Rust is currently unavailable on
                 ;; non-x86_64 platforms, we use SDDM and Mate here instead of
                 ;; GNOME and GDM.
                 (append (list (service mate-desktop-service-type)
                               (service xfce-desktop-service-type)
                               (set-xorg-configuration
                                (xorg-configuration
                                 (keyboard-layout keyboard-layout))
                                sddm-service-type))
                         %desktop-services)))

   ;; Allow resolution of '.local' host names with mDNS.
   (name-service-switch %mdns-host-lookup-nss)))
