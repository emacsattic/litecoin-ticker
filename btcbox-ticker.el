;;; btcbox-ticker --- show japanese bitcoin price on btcbox

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
(require 'json)
(require 'url)

;; --- variable definition -----

(defvar btcbox-url "https://www.btcbox.co.jp/api/v1/ticker/"
  "Btcbox api url")

(defvar btcbox-ticker-mode-line nil
  "Btcbox ticker modeline")

(defvar btcbox-ticker-timer nil
  "Stores the timer to display bitcoin ticker")

(defcustom btcbox-ticker-timer-interval 10
  "Stores the timer interval"
  :type 'integer)

;; --- Fucntion definition -----

(defun btcbox-ticker-api-data ()
  "Retrieve the api data from `btcbox-url', and convert it to json data."
  (let (info sell-price buy-price)
    (with-current-buffer (url-retrieve-synchronously btcbox-url)
      (setq info (json-read-from-string
		  (buffer-substring url-http-end-of-headers (point-max)))))
    (setq sell-price (cdr (assoc 'sell info)))
    (setq buy-price (cdr (assoc 'buy info)))
    (setq btcbox-ticker-mode-line
	  (format " [Sell:¥%s Buy:¥%s]" sell-price buy-price))
    (list sell-price buy-price))) 

;;;###autoload
(define-minor-mode btcbox-ticker-mode
  "Minor mode to display btcbox ticker"
  :init-value nil
  :global nil
  :lighter btcbox-ticker-mode-line
  (if btcbox-ticker-mode
      (setq btcbox-ticker-timer
	    (run-at-time 0
			 btcbox-ticker-timer-interval 'btcbox-ticker-api-data))
    (cancel-timer btcbox-ticker-timer)
    (setq btcbox-ticker-timer nil)))

(provide 'btcbox-ticker)
;;; btcbox-ticker.el ends here
