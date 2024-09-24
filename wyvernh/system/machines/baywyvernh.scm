(define-module (wyvernh system machines baywyvernh)
  #:use-module (wyvernh system machines)
  #:use-module (wyvernh system btrfs)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:export (wyvernh-system-baywyvernh))

(define fs-root
  (file-system
   (mount-point "/")
   (type "btrfs")
   (device (file-system-label "Guix"))
   ;(options (wyvernh-btrfs-mount-options "@"))
   (needed-for-boot? #t)))

(define fs-efi
  (file-system
    (mount-point "/efi")
    (device (file-system-label "EFI SYSTEM"))
    (type "vfat")))

;(define fs-swap
;  (file-system
;   (mount-point "/swap")
;   (type "btrfs")
;   (device (file-system-label "nvme-root"))
;   (options "subvol=@swap")
;   (needed-for-boot? #t)))

;(define fs-home
;  (file-system
;   (mount-point "/home")
;   (type "btrfs")
;   (device (file-system-label "nvme-root"))
;   (options (plt-btrfs-mount-options "@home"))))

;(define fs-snapshots
;  (file-system
;   (mount-point "/.snapshots")
;   (type "btrfs")
;   (device (file-system-label "nvme-root"))
;   (options (plt-btrfs-mount-options "@snapshots"))))

(define wyvernh-system-bawyvernh
  (operating-system
    (inherit %wyvernh-base-operating-system)
    (host-name "baywyvernh")
    (file-systems
     (cons*
      fs-root
      fs-efi
      %base-file-systems))
    (swap-devices
     (list
      (swap-space
       (target (file-system-label "Swap")))))
    (services
     (cons*
      ;(service guix-publish-service-type
      ;         (guix-publish-configuration
      ;          (host "::")
      ;          (advertise? #t)))
      ;(simple-service 'hidpi-setup session-environment-service-type
      ;                '(("GDK_DPI_SCALE" . "1.7")
      ;                  ("QT_AUTO_SCREEN_SCALE_FACTOR" . "1")))
      %wyvernh-base-services))))

wyvernh-system-bawyvernh
