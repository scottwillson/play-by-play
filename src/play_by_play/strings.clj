(ns play-by-play.strings
  (:require [clojure.string :as str]))

(defn to-camel-case [k]
  (let [s (if (keyword? k) (name k) k)]
    (str/replace s #"\-[A-z]" (fn [[dash letter]]
                            (.toUpperCase (str letter))))))
