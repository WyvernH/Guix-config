(define-module (wyvernh system btrfs)
  #:export (wyvernh-btrfs-mount-options))

(define* (wyvernh-btrfs-mount-options subvol #:key (ssd? #t))
  "Return the btrfs mount options I use.
   Where SUBVOL is the subvolume to mount."
  (string-join `(,@(if ssd? (list "discard") '())
                 "compress=zstd"
                 ,(format #f "subvol=~a" subvol)) ","))
