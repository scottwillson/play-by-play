(ns play-by-play.assertions
  (:require [clojure.test :refer :all]))

(defn realistic-score? [score]
  (and
    (> score 50)
    (< score 160)))

(defn realistic-game-score? [game]
  (is
    (and (realistic-score? (:home-score game))
         (realistic-score? (:visitor-score game)))))
