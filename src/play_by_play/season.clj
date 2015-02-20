(ns play-by-play.season
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(def score
  (stats/sample rw/scores))

(def season
  (repeat (* 30 42)
    score))
