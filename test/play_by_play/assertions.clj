(ns play-by-play.assertions
  (:require [clojure.test :refer :all]))

(defn realistic-score? [score]
  (and
    (> score 50)
    (< score 160)))

(defn realistic-game-score? [score]
  (let [[v h] score]
    (is
      (and (realistic-score? v)
           (realistic-score? h)))))

