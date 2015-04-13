(ns play-by-play.assertions
  (:require [clojure.test :refer :all]))

(defn realistic-score? [score]
  (and
    (> score 50)
    (< score 160)))

(defn realistic-game-score? [game]
  (is
    (and (realistic-score? (:points (first (:teams game))))
         (realistic-score? (:points (last (:teams game)))))))
