;;; litecoin-ticker --- show litecoin price

;; Copyright (C) 2016  Zhe Lei.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Code:

(defvar litecoin-ticker-url "https://btc-e.com/api/2/ltc_usd/ticker")

(defvar litecoin-ticker-mode-line " $0.00")

(defvar litecoin-ticker-timer nil)

(defun litecoin-ticker-poll-info ()
  (let (json info price)
    (with-current-buffer (url-retrieve-synchronously litecoin-ticker-url t)
      (goto-char (point-min))
      (re-search-forward "gzip" nil 'move)
      (setq json (buffer-substring-no-properties (point) (point-max))))
    (setq info (car (json-read-from-string json)))
    (setq price (assoc-default 'buy info))
    (setq litecoin-ticker-mode-line
          (format " $%s" price))))

(define-minor-mode litecoin-ticker-mode
  "Minor mode to display the last litecoin price"
  :init-value nil
  :global t
  :lighter litecoin-ticker-mode-line
  (if litecoin-ticker-mode
      (setq litecoin-ticker-timer
	    (run-at-time "0 sec" 10 #'litecoin-ticker-poll-info))
    (cancel-timer litecoin-ticker-timer)
    (setq litecoin-ticker-timer nil)))

