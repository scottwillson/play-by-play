(ns play-by-play.core
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

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
      "mean"
      (stats/mean rw/scores))))

(def score
  (stats/sample rw/scores))

(def season
  (repeat (* 30 42)
    score))
