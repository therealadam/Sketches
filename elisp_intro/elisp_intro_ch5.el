(defun greater-than (&optional value)
  (interactive "N")
  (let ((v (or value fill-column)))
    (> v 56)))

(greater-than)
(greater-than 14)
