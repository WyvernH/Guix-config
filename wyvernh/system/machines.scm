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

   (file-systems (append
                  (list (file-system
                         (device (file-system-label "Guix"))
                         (mount-point "/")
                         (type "btrfs"))
                        (file-system
                         (device (file-system-label "EFI SYSTEM"))
                         (mount-point "/efi")
                         (type "vfat")))
                  %base-file-systems))

   (swap-devices (list (swap-space
                        (target (file-system-label "Swap")))))

   (users (cons (user-account
                 (name "matthew")
                 (comment "Matthew Hinton")
                 (group "users")
                 (supplementary-groups '("wheel" "netdev"
                                         "audio" "video")))
                %base-user-accounts))

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
