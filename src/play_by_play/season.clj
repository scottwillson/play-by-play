(ns play-by-play.season
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(defn score []
  (stats/sample rw/scores :size 1))

(defn team []
  (stats/sample rw/teams :size 1))

(defn game []
  { :home-team     (team)
    :visitor-team  (team)
    :home-score    (score)
    :visitor-score (score) })

(defn day [& date]
  (repeatedly 2 game))

(def season
  (repeatedly (* 30 42) game))
