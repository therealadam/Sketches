(defun double (x)
  "Double the value of X"
  (interactive "p")
  (message "X * 2 is %d" (* x 2)))

(double 4)

(defun is-greater-than-fill-column (x)
  "Displays a message indicating whether X is greater than fill-column"
  (if (> fill-column x)
      (message "%d is greater than fill-column" x)
    (message "%d is less than fill-column" x)))

(is-greater-than-fill-column 89)

