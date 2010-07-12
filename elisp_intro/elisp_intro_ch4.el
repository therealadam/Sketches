(defun simplified-end-of-buffer ()
  (interactive)
  "Move the point to the end of the buffer"
  (goto-char (point-max)))

(defun buffer-exists-p (name)
  (interactive "s")
  (if (get-buffer name)
      (message "Buffer %s exists" name)
    (message "Buffer %s does not exist" name)))
