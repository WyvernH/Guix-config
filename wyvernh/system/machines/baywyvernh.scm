(define-module (wyvernh system machines baywyvernh)
  #:use-module (wyvernh system machines)
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
    (host-name "baywyvernh")))

wyvernh-system-bawyvernh
