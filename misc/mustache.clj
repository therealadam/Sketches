(ns mustache
  (:use clojure.contrib.str-utils))

(defn mustache [template view]
  (let [target (last (re-find #"\{\{ ([w]+) \}\}" template))
        result (re-gsub (re-pattern target) template (view target))]
    target))

;; ({"dog" "Arf!"} "dog")

;; (re-gsub #"foo" "bar" "foo")
(mustache "{{ foo }}" {:dog "Arf!"})
