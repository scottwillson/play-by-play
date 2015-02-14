(ns play-by-play.core
  (:require [play-by-play.real-world :as rw])
  (:gen-class))

(defn average [coll]
  (float (/ (reduce + coll) (count coll))))

(defn -main
  [& args]
  (do
    (println
      "minimum"
      (apply min rw/scores))
    (println
      "maximum"
      (apply max rw/scores))
    (println
      "average"
      (average rw/scores))))

(def score
  [95, 98])

(def season
  (repeat (* 30 42)
    score))
